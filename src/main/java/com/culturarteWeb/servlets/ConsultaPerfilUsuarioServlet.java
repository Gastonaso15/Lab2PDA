package com.culturarteWeb.servlets;

import culturarte.logica.DTs.*;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.IUsuarioController;
import culturarte.logica.controladores.PropuestaController;
import culturarte.logica.controladores.UsuarioController;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/consultaPerfilUsuario")
public class ConsultaPerfilUsuarioServlet extends HttpServlet {

    private IUsuarioController ICU;
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        // En tu Lab1PDA no hay Fabrica, las implementaciones concretas se instancian directo:
        ICU = new UsuarioController();
        IPC = new PropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String nick = req.getParameter("nick");

        // 1) Sin nick: listar usuarios (por nickname) para elegir
        if (nick == null || nick.isBlank()) {
            try {
                List<String> nicks = ICU.devolverNicknamesUsuarios();
                req.setAttribute("nicknames", nicks);
            } catch (Exception e) {
                req.setAttribute("error", "No se pudo listar usuarios: " + e.getMessage());
            }
            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
            return;
        }

        // 2) Con nick: armar perfil completo
        try {
            // ¿Quién está logueado? (si ya manejás sesión de esta forma)
            HttpSession ses = req.getSession(false);
            DTUsuario actual = (ses != null) ? (DTUsuario) ses.getAttribute("usuarioLogueado") : null;
            boolean esPropio = (actual != null && nick.equalsIgnoreCase(actual.getNickname()));

            // Intento como Proponente, si no es, lo intento como Colaborador
            DTProponente proponente = null;
            DTColaborador colaborador = null;
            DTUsuario base;

            try {
                proponente = ICU.devolverProponentePorNickname(nick); // si no existe tira Exception
                base = proponente;
            } catch (Exception ex) {
                // no era proponente, pruebo colaborador
                colaborador = ICU.devolverColaboradorPorNickname(nick);
                base = colaborador;
            }

            if (base == null) {
                req.setAttribute("error", "El usuario '" + nick + "' no existe.");
                req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
                return;
            }

            // Siguiendo (nicknames)
            List<String> siguiendoNicks = safe(() -> ICU.devolverUsuariosSeguidos(nick), new ArrayList<>());

            // Seguidores (nicknames) – no hay método directo, lo calculamos
            List<String> todos = safe(ICU::devolverNicknamesUsuarios, new ArrayList<>());
            List<String> seguidoresNicks = new ArrayList<>();
            for (String otro : todos) {
                if (otro.equalsIgnoreCase(nick)) continue;
                List<String> siguiendoDeOtro = safe(() -> ICU.devolverUsuariosSeguidos(otro), new ArrayList<>());
                if (siguiendoDeOtro.stream().anyMatch(n -> n.equalsIgnoreCase(nick))) {
                    seguidoresNicks.add(otro);
                }
            }

            // Resolución de tipo (Proponente/Colaborador) para mostrar pill
            Map<String, String> tipoPorNick = new HashMap<>();
            for (String n : union(siguiendoNicks, seguidoresNicks)) {
                String tipo = resolveTipoUsuario(ICU, n);
                tipoPorNick.put(n, tipo);
            }

            // Favoritas: no hay lista, así que recorro todas y pregunto por cada una
            List<DTPropuesta> todas = safe(IPC::devolverTodasLasPropuestas, new ArrayList<>());
            List<DTPropuesta> favoritas = new ArrayList<>();
            for (DTPropuesta p : todas) {
                // En tu interfaz el método se llama "UsuarioYaTienePropuestaFavorita(nick, titulo)"
                boolean esFav = safe(() -> ICU.UsuarioYaTienePropuestaFavorita(nick, p.getTitulo()), false);
                if (esFav) favoritas.add(p);
            }

            // Publicadas (no INGRESADA) si es Proponente
            List<DTPropuesta> publicadasNoIngresada = new ArrayList<>();
            List<DTPropuesta> creadasIngresadas = new ArrayList<>();
            if (proponente != null && proponente.getPropuestas() != null) {
                for (DTPropuesta p : proponente.getPropuestas()) {
                    DTEstadoPropuesta est = p.getEstadoActual();
                    if (est != null) {
                        if (est != DTEstadoPropuesta.INGRESADA) publicadasNoIngresada.add(p);
                        if (esPropio && est == DTEstadoPropuesta.INGRESADA) creadasIngresadas.add(p);
                    }
                }
            }

            // Colaboradas si es Colaborador
            List<DTPropuesta> colaboradas = new ArrayList<>();
            List<DTColaboracion> misColaboraciones = new ArrayList<>();
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                misColaboraciones = colaborador.getColaboraciones();
                for (DTColaboracion c : misColaboraciones) {
                    if (c.getPropuesta() != null) colaboradas.add(c.getPropuesta());
                }
            }

            // ¿El actual ya lo sigue? (si hay sesión y no es propio)
            boolean loSigo = false;
            if (actual != null && !esPropio) {
                loSigo = safe(() -> ICU.UsuarioUnoYaSigueUsuarioDos(actual.getNickname(), nick), false);
            }

            // Seteos a la vista
            req.setAttribute("usuarioConsultado", base);
            req.setAttribute("esPropio", esPropio);
            req.setAttribute("usuarioActual", actual);

            req.setAttribute("siguiendoNicks", siguiendoNicks);
            req.setAttribute("seguidoresNicks", seguidoresNicks);
            req.setAttribute("tipoPorNick", tipoPorNick);

            req.setAttribute("favoritas", favoritas);
            req.setAttribute("publicadasNoIngresada", publicadasNoIngresada);
            req.setAttribute("colaboradas", colaboradas);

            req.setAttribute("creadasIngresadas", creadasIngresadas);
            req.setAttribute("misColaboraciones", misColaboraciones);

            req.setAttribute("esProponente", proponente != null);
            req.setAttribute("esColaborador", colaborador != null);
            req.setAttribute("loSigo", loSigo);

            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("error", "Error al consultar perfil: " + e.getMessage());
            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
        }
    }

    // Helpers

    private static <T> T safe(CallableEx<T> c, T def) {
        try { return c.call(); } catch (Exception e) { return def; }
    }
    private interface CallableEx<T> { T call() throws Exception; }

    private static List<String> union(List<String> a, List<String> b) {
        return new ArrayList<>(new LinkedHashSet<>(combine(a, b)));
    }
    private static List<String> combine(List<String> a, List<String> b) {
        List<String> r = new ArrayList<>();
        if (a != null) r.addAll(a);
        if (b != null) r.addAll(b);
        return r;
    }

    private static String resolveTipoUsuario(IUsuarioController ICU, String nick) {
        try { ICU.devolverProponentePorNickname(nick); return "Proponente"; }
        catch (Exception __) { /* ignore */ }
        try { ICU.devolverColaboradorPorNickname(nick); return "Colaborador"; }
        catch (Exception __) { /* ignore */ }
        return "Usuario";
    }
}