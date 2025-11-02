package com.culturarteWeb.servlets;
import com.culturarteWeb.util.WSConsumer;
import com.culturarteWeb.ws.propuestas.*;
import com.culturarteWeb.ws.usuarios.DtProponente;
import com.culturarteWeb.ws.propuestas.DtPropuesta;
import com.culturarteWeb.ws.usuarios.DtColaborador;
import com.culturarteWeb.ws.usuarios.DtUsuario;
import com.culturarteWeb.ws.usuarios.IUsuarioControllerWS;
import com.culturarteWeb.ws.usuarios.ListaStrings;
import com.culturarteWeb.ws.usuarios.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.util.*;

@WebServlet("/consultaPerfilUsuario")
public class ConsultaPerfilUsuarioServlet extends HttpServlet {

    IPropuestaControllerWS IPC = WSConsumer.get().propuestas();
    IUsuarioControllerWS IUC = WSConsumer.get().usuarios();

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            IUC = usuarioServicio.getUsuarioWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }


    //Obtengo los Nicknames de los usuarios para poder preguntar al usuario activo por cual quiere consultar
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String nick = req.getParameter("nick");
        //Muestro la lista de usuarios disponibles a consultar
        if (nick == null || nick.isBlank()) {
            try {
                ListaStrings nicksWS = IUC.devolverNicknamesUsuarios();
                List<String> nicks = nicksWS.getItem();
                List<Map<String, Object>> usuariosCombo = new ArrayList<>();
                for (String n : nicks) {
                    DtUsuario u = IUC.obtenerUsuarioPorNickname(n);
                    if (u == null) continue;

                    String tipo;
                    try {
                        IUC.devolverProponentePorNickname(n);
                        tipo = "Proponente";
                    } catch (Exception ex) {
                        tipo = "Colaborador";
                    }

                    Map<String, Object> row = new HashMap<>();
                    row.put("nick", u.getNickname());
                    row.put("nombre", u.getNombre());
                    row.put("apellido", u.getApellido());
                    row.put("tipo", tipo);
                    usuariosCombo.add(row);
                }

                // ordenado por id ascendente
                //usuariosCombo.sort(Comparator.comparingLong(m -> (Long) m.get("id")));
                // Opción A: usa un valor por defecto cuando no haya "id"
                usuariosCombo.sort(Comparator.comparingLong(m -> ((Number) m.getOrDefault("id", Long.MAX_VALUE)).longValue()));
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
            DtUsuario actual = (ses != null) ? (DtUsuario) ses.getAttribute("usuarioLogueado") : null;
            boolean esPropio = (actual != null && nick.equalsIgnoreCase(actual.getNickname()));
            // Intento como Proponente, si no es, lo intento como Colaborador
            DtProponente proponente = null;
            DtColaborador colaborador = null;
            DtUsuario defenza; //lo uso como una defenza, para evitar errores en el caso de que no exista ninguno.
            try {
                proponente = IUC.devolverProponentePorNickname(nick); // si no existe tira Exception
                defenza = proponente;
            } catch (Exception ex) {
                // no era proponente, pruebo colaborador
                colaborador = IUC.devolverColaboradorPorNickname(nick);
                defenza = colaborador;
            }

            if (defenza == null) {
                req.setAttribute("error", "El usuario '" + nick + "' no existe.");
                req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
                return;
            }

            DtUsuario usuarioConsultado = (proponente != null) ? proponente : colaborador;
            req.setAttribute("usuarioConsultado", usuarioConsultado);

            //<-- PROCEDO A RECOLECTAR LA INFO QUE VOY A MOSTRAR -->

            // <-- 1: Armo lista de "siguiendo" (a quién sigue 'nick') -->
            List<String> siguiendoProponentes = new ArrayList<>();
            List<String> siguiendoColaboradores = new ArrayList<>();

            ListaStrings nicksWS = IUC.devolverUsuariosSeguidos(nick);
            List<String> siguiendoNicks = nicksWS.getItem();

            for (String s : siguiendoNicks) {
                boolean esProp = false;
                try {
                    esProp = (IUC.devolverProponentePorNickname(s) != null);
                } catch (Exception ignore) { }

                if (esProp) siguiendoProponentes.add(s);
                else        siguiendoColaboradores.add(s);
            }

            // <-- 2: Armo lista de seguidores -->
            List<String> followers = (List<String>) IUC.obtenerFollowers(nick);
            List<String> followersProponentes = new ArrayList<>();
            List<String> followersColaboradores = new ArrayList<>();
            for (String f : followers) {
                boolean esProp = false;
                try {
                    esProp = (IUC.devolverProponentePorNickname(f) != null);
                } catch (Exception ignore) { }
                if (esProp) followersProponentes.add(f);
                else        followersColaboradores.add(f);
            }


            // <-- 3: Armo lista de Propuestas Favoritas -->
            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasProp = propuestasWS.getPropuesta();

            List<DtPropuesta> favoritas = new ArrayList<>();
            for (DtPropuesta propuesta : todasLasProp) {
                boolean esFav = IUC.usuarioYaTienePropuestaFavorita(nick, propuesta.getTitulo());
                if (esFav) {
                    favoritas.add(propuesta);
                }
            }

            // <-- 4: Armo lista de todas las Propuestas que el Proponente registrado publicó menos las que están en estado INGREADAS, y otra en que solo están las que esten en estado INGRESADA-->
            //<--Separo Propuestas entre INGRESADAS y todos los demas estados; La unica forma de ver las INGRESADAS es si un Proponente entra a su propio perfil -->
            List<com.culturarteWeb.ws.usuarios.DtPropuesta> publicadasNoIngresada = new ArrayList<>();
            List<com.culturarteWeb.ws.usuarios.DtPropuesta> creadasIngresadas = new ArrayList<>();
            List<com.culturarteWeb.ws.usuarios.DtPropuesta> porpuestasProponente = proponente.getPropuestas();
            if (proponente != null && proponente.getPropuestas() != null) {
                for (com.culturarteWeb.ws.usuarios.DtPropuesta p : proponente.getPropuestas()) {
                    com.culturarteWeb.ws.usuarios.DtEstadoPropuesta est = p.getEstadoActual();
                    if (est != null) {
                        if (est != com.culturarteWeb.ws.usuarios.DtEstadoPropuesta.INGRESADA) publicadasNoIngresada.add(p);
                        if (esPropio && est == com.culturarteWeb.ws.usuarios.DtEstadoPropuesta.INGRESADA) creadasIngresadas.add(p);
                    }
                }
            }

            //  <-- 5: Armo lista de Propuestas en que el Colaborador colaboró -->
            List<com.culturarteWeb.ws.usuarios.DtPropuesta> colaboradas = new ArrayList<>();
            List<com.culturarteWeb.ws.usuarios.DtColaboracion> misColaboraciones = new ArrayList<>();
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                misColaboraciones = colaborador.getColaboraciones();
                for (com.culturarteWeb.ws.usuarios.DtColaboracion c : misColaboraciones) {
                    if (c.getPropuesta() != null) colaboradas.add(c.getPropuesta());
                }
            }

            boolean loSigo = false;
            if (actual != null && usuarioConsultado != null) {
                ListaStrings usuariosWS = IUC.devolverUsuariosSeguidos(actual.getNickname());
                List<String> usuariosSeguidos  = usuariosWS.getItem();

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
