package com.culturarteWeb.servlets;

import culturarte.logica.DTs.*;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.IUsuarioController;
import culturarte.logica.controladores.PropuestaController;
import culturarte.logica.controladores.UsuarioController;

import culturarte.logica.manejadores.UsuarioManejador;
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

        ICU = new UsuarioController();
        IPC = new PropuestaController();
    }


    //Obtengo los Nicknames de los usuarios para poder preguntar al usuario activo por cual quiere consultar
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String nick = req.getParameter("nick");
        if (nick == null || nick.isBlank()) {
            try {
                //*1: --> ESTO ME PASA AL JSP LOS DATOS QUE SOLICITO: nicks es la variable en que guardo la lista de strings y "nicknames" es el nombre que uso
                // como medio para mandarselo al jsp
                List<String> nicks = ICU.devolverNicknamesUsuarios();
                //Seteo los nicks que acabo de obtener del controlador del servidor central mediante la fabrica que me dio a ICU
                req.setAttribute("nicknames", nicks);
            } catch (Exception e) {
                req.setAttribute("error", "No se pudo listar usuarios: " + e.getMessage());
            }
            //envio los datos ya cargados al jsp con el Dispatcher (si hasta parece despachador en español ahora que veo)
            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
            return;
        }




        try {
            //Obtengo el usuario que está logueado y averiguo de quá tipo es para saber qué muestro y qué no
            boolean esProponente = false;
            boolean esColaborador = false;
            boolean esVisitante = false;
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("usuarioLogueado") != null) {
                DTUsuario usuarioLogueado = (DTUsuario) session.getAttribute("usuarioLogueado");
                try {
                    ICU.devolverProponentePorNickname(usuarioLogueado.getNickname());
                    esProponente = true;
                } catch (Exception e) {
                    esColaborador = true;
                }
            }
            if (esProponente == false && esColaborador ==false){
                esVisitante = true;
            }



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
            //<-- 1: Armo lista de seguidos -->
            List<String> siguiendoNicks = ICU.devolverUsuariosSeguidos(nick); //este es el nick que obtendo del doGet()
            //Separo lista en lista de Proponentes y lista de Colaboradores
            List<String> siguiendoProponentes = new ArrayList<>();
            List<String> siguiendoColaboradores = new ArrayList<>();
            for (String s : siguiendoNicks) {
                if (ICU.devolverProponentePorNickname(s) != null) {
                    siguiendoProponentes.add(s);
                }else{
                    siguiendoColaboradores.add(s);
                }
            }

            // <-- 2: Armo lista de seguidores -->
            UsuarioManejador mu = UsuarioManejador.getInstance();
            List<String> followers = mu.obtenerFollowers(nick);
            //Separo lista en lista de Proponentes y lista de Colaboradores
            List<String> followersProponentes = new ArrayList<>();
            List<String> followersColaboradores = new ArrayList<>();
            for (String f : followers) {
                if (ICU.devolverProponentePorNickname(f) != null) {
                    followersProponentes.add(f);
                }else{
                    followersColaboradores.add(f);
                }
            }



            //CREO LA LISTA DE PROPUESTAS FAVORITAS
            List<DTPropuesta> todasLasProp = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> favoritas = new ArrayList<>();
            for (DTPropuesta propuesta : todasLasProp) {
                boolean esFav = ICU.UsuarioYaTienePropuestaFavorita(nick, propuesta.getTitulo());
                if (esFav) {
                    favoritas.add(propuesta);
                }
            }

            //<--Separo Propuestas entre INGRESADAS y todos los demas estados; La unica forma de ver las INGRESADAS es si un Proponente entra  -->
            //<--A su propio perfil -->
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




            // Seteos a la vista
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