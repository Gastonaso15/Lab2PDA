/*
package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtColaboracion;
import culturarte.servicios.cliente.propuestas.DtComentario;
import culturarte.servicios.cliente.usuario.DtEstadoPropuesta;
import culturarte.servicios.cliente.propuestas.DtPropuesta;
import culturarte.servicios.cliente.usuario.ListaStrings;
import culturarte.servicios.cliente.usuario.*;
import culturarte.servicios.cliente.usuario.DtColaborador;
import culturarte.servicios.cliente.usuario.DtProponente;
import culturarte.servicios.cliente.usuario.DtUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.util.*;

@WebServlet("/consultaPerfilUsuario")
public class ConsultaPerfilUsuarioServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();

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
                ListaStrings nicksWS = ICU.devolverNicknamesUsuarios();
                List<String> nicks = nicksWS.getItem();

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
            DtUsuario actual = (ses != null) ? (DtUsuario) ses.getAttribute("usuarioLogueado") : null;
            boolean esPropio = (actual != null && nick.equalsIgnoreCase(actual.getNickname()));
            // Intento como Proponente, si no es, lo intento como Colaborador
            DtProponente proponente = null;
            DtColaborador colaborador = null;
            DtUsuario defenza; //lo uso como una defenza, para evitar errores en el caso de que no exista ninguno.
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

            DtUsuario usuarioConsultado = (proponente != null) ? proponente : colaborador;
            req.setAttribute("usuarioConsultado", usuarioConsultado);

            //<-- PROCEDO A RECOLECTAR LA INFO QUE VOY A MOSTRAR -->

            // <-- 1: Armo lista de "siguiendo" (a quién sigue 'nick') -->
            List<String> siguiendoProponentes = new ArrayList<>();
            List<String> siguiendoColaboradores = new ArrayList<>();

            ListaStrings nicksWS = ICU.devolverUsuariosSeguidos(nick);
            List<String> siguiendoNicks = nicksWS.getItem();

            for (String s : siguiendoNicks) {
                boolean esProp = false;
                try {
                    esProp = (ICU.devolverProponentePorNickname(s) != null);
                } catch (Exception ignore) { }

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
            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasProp = propuestasWS.getPropuesta();

            List<DtPropuesta> favoritas = new ArrayList<>();
            for (DtPropuesta propuesta : todasLasProp) {
                boolean esFav = ICU.usuarioYaTienePropuestaFavorita(nick, propuesta.getTitulo());
                if (esFav) {
                    favoritas.add(propuesta);
                }
            }

            // <-- 4: Armo lista de todas las Propuestas que el Proponente registrado publicó menos las que están en estado INGREADAS, y otra en que solo están las que esten en estado INGRESADA-->
            //<--Separo Propuestas entre INGRESADAS y todos los demas estados; La unica forma de ver las INGRESADAS es si un Proponente entra a su propio perfil -->
            List<DtPropuesta> publicadasNoIngresada = new ArrayList<>();
            List<DtPropuesta> creadasIngresadas = new ArrayList<>();
            if (proponente != null && proponente.getPropuestas() != null) {
                for (culturarte.servicios.cliente.usuario.DtPropuesta p : proponente.getPropuestas()) {
                    DtEstadoPropuesta est = p.getEstadoActual();
                    if (est != null) {
                        if (est != DtEstadoPropuesta.INGRESADA) publicadasNoIngresada.add(p);
                        if (esPropio && est == DtEstadoPropuesta.INGRESADA) creadasIngresadas.add(p);
                    }
                }
            }

            //  <-- 5: Armo lista de Propuestas en que el Colaborador colaboró -->
            List<DtPropuesta> colaboradas = new ArrayList<>();
            List<DtColaboracion> misColaboraciones = new ArrayList<>();
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                misColaboraciones = colaborador.getColaboraciones();
                for (DtColaboracion c : misColaboraciones) {
                    if (c.getPropuesta() != null) colaboradas.add(c.getPropuesta());
                }
            }

            boolean loSigo = false;
            if (actual != null && usuarioConsultado != null) {
                ListaStrings usuariosWS = ICU.devolverUsuariosSeguidos(actual.getNickname());
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
*/