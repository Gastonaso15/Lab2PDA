package com.culturarteWeb.servlets;

import culturarte.logica.DTs.*;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.IUsuarioController;
import culturarte.logica.controladores.PropuestaController;
import culturarte.logica.controladores.UsuarioController;

import culturarte.logica.manejadores.UsuarioManejador;
import culturarte.logica.modelos.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/consultaPerfilUsuario")
public class ConsultaPerfilUsuarioServlet extends HttpServlet {

    private IUsuarioController ICU;
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        Fabrica fabrica = Fabrica.getInstance();
        ICU = fabrica.getIUsuarioController();
        IPC = fabrica.getIPropuestaController();
    }


    //Obtengo los Nicknames de los usuarios para poder preguntar al usuario activo por cual quiere consultar
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String nick = req.getParameter("nick");
        //Muestro la lista de usuarios disponibles a consultar
        if (nick == null || nick.isBlank()) {
            try {
                List<String> nicks = ICU.devolverNicknamesUsuarios();

                UsuarioManejador UM = UsuarioManejador.getInstance();
                List<Map<String, Object>> usuariosCombo = new ArrayList<>();

                for (String n : nicks) {
                    Usuario u = UM.obtenerUsuarioPorNickname(n);
                    if (u == null) continue;

                    String tipo;
                    try {
                        ICU.devolverProponentePorNickname(n);
                        tipo = "Proponente";
                    } catch (Exception ex) {
                        tipo = "Colaborador";
                    }

                    Map<String, Object> row = new HashMap<>();
                    row.put("id", u.getId());
                    row.put("nick", u.getNickname());
                    row.put("nombre", u.getNombre());
                    row.put("apellido", u.getApellido());
                    row.put("tipo", tipo);
                    usuariosCombo.add(row);
                }

                // ordenado por id ascendente
                usuariosCombo.sort(Comparator.comparingLong(m -> (Long) m.get("id")));

                // Seteo la lista enriquecida para el JSP
                req.setAttribute("usuariosCombo", usuariosCombo);

            } catch (Exception e) {
                req.setAttribute("error", "No se pudo listar usuarios: " + e.getMessage());
            }
            //envio los datos ya cargados al jsp con el Dispatcher (si hasta parece despachador en español ahora que veo)
            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
            return;
        }


        //Procedo a consultar el perfil deseado
        try {
            //averiguo frente a que tipo de usuario estoy para saber despues que le muestro
            HttpSession ses = req.getSession(false);
            DTUsuario actual = (ses != null) ? (DTUsuario) ses.getAttribute("usuarioLogueado") : null;
            boolean esPropio = (actual != null && nick.equalsIgnoreCase(actual.getNickname()));
            // Intento como Proponente, si no es, lo intento como Colaborador
            DTProponente proponente = null;
            DTColaborador colaborador = null;
            DTUsuario defenza; //lo uso como una defenza, para evitar errores en el caso de que no exista ninguno.
            try {
                proponente = ICU.devolverProponentePorNickname(nick); // si no existe tira Exception
                defenza = proponente;
            } catch (Exception ex) {
                // no era proponente, pruebo colaborador
                colaborador = ICU.devolverColaboradorPorNickname(nick);
                defenza = colaborador;
            }

            if (defenza == null) {
                req.setAttribute("error", "El usuario '" + nick + "' no existe.");
                req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
                return;
            }

            DTUsuario usuarioConsultado = (proponente != null) ? proponente : colaborador;
            req.setAttribute("usuarioConsultado", usuarioConsultado);

            //<-- PROCEDO A RECOLECTAR LA INFO QUE VOY A MOSTRAR -->

            // <-- 1: Armo lista de "siguiendo" (a quién sigue 'nick') -->
            List<String> siguiendoProponentes = new ArrayList<>();
            List<String> siguiendoColaboradores = new ArrayList<>();
            List<String> siguiendoNicks = ICU.devolverUsuariosSeguidos(nick);

            for (String s : siguiendoNicks) {
                boolean esProp = false;
                try {
                    esProp = (ICU.devolverProponentePorNickname(s) != null);
                } catch (Exception ignore) { /* no es proponente */ }

                if (esProp) siguiendoProponentes.add(s);
                else        siguiendoColaboradores.add(s);
            }

            // <-- 2: Armo lista de seguidores -->
            UsuarioManejador mu = UsuarioManejador.getInstance();
            List<String> followers = mu.obtenerFollowers(nick);

            List<String> followersProponentes = new ArrayList<>();
            List<String> followersColaboradores = new ArrayList<>();
            for (String f : followers) {
                boolean esProp = false;
                try {
                    esProp = (ICU.devolverProponentePorNickname(f) != null);
                } catch (Exception ignore) { }
                if (esProp) followersProponentes.add(f);
                else        followersColaboradores.add(f);
            }


            // <-- 3: Armo lista de Propuestas Favoritas -->
            List<DTPropuesta> todasLasProp = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> favoritas = new ArrayList<>();
            for (DTPropuesta propuesta : todasLasProp) {
                boolean esFav = ICU.UsuarioYaTienePropuestaFavorita(nick, propuesta.getTitulo());
                if (esFav) {
                    favoritas.add(propuesta);
                }
            }

            // <-- 4: Armo lista de todas las Propuestas que el Proponente registrado publicó menos las que están en estado INGREADAS, y otra en que solo están las que esten en estado INGRESADA-->
            //<--Separo Propuestas entre INGRESADAS y todos los demas estados; La unica forma de ver las INGRESADAS es si un Proponente entra a su propio perfil -->
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

            //  <-- 5: Armo lista de Propuestas en que el Colaborador colaboró -->
            List<DTPropuesta> colaboradas = new ArrayList<>();
            List<DTColaboracion> misColaboraciones = new ArrayList<>();
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                misColaboraciones = colaborador.getColaboraciones();
                for (DTColaboracion c : misColaboraciones) {
                    if (c.getPropuesta() != null) colaboradas.add(c.getPropuesta());
                }
            }

            boolean loSigo = false;
            if (actual != null && usuarioConsultado != null) {
                List<String> usuariosSeguidos = ICU.devolverUsuariosSeguidos(actual.getNickname());
                loSigo = usuariosSeguidos.contains(usuarioConsultado.getNickname());
            }
            req.setAttribute("loSigo", loSigo);


            // Seteo los atributos que mando al jsp
            req.setAttribute("esPropio", esPropio);
            req.setAttribute("usuarioActual", actual);
            req.setAttribute("siguiendoProponentes", siguiendoProponentes);
            req.setAttribute("siguiendoColaboradores", siguiendoColaboradores);
            req.setAttribute("followersProponentes", followersProponentes);
            req.setAttribute("followersColaboradores", followersColaboradores);
            req.setAttribute("favoritas", favoritas);
            req.setAttribute("publicadasNoIngresada", publicadasNoIngresada);
            req.setAttribute("colaboradas", colaboradas);
            req.setAttribute("creadasIngresadas", creadasIngresadas);
            req.setAttribute("misColaboraciones", misColaboraciones);
            req.setAttribute("esProponente", proponente != null);
            req.setAttribute("esColaborador", colaborador != null);


            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);

        } catch (Exception e) {
        e.printStackTrace();
            req.setAttribute("error", "Error al consultar perfil: " + e.getMessage());
            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
        }
    }

}