package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtColaboracion;
import culturarte.servicios.cliente.usuario.DtEstadoPropuesta;
import culturarte.servicios.cliente.propuestas.DtPropuesta;
import culturarte.servicios.cliente.usuario.ListaStrings;
import culturarte.servicios.cliente.usuario.*;
import culturarte.servicios.cliente.usuario.DtColaborador;
import culturarte.servicios.cliente.usuario.DtProponente;
import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.ListaDTProponente;
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
            // habilita dump SOAP en el CLIENTE (tu webapp)
            System.setProperty("com.sun.xml.ws.transport.http.client.HttpTransportPipe.dump", "true");
            System.setProperty("com.sun.xml.internal.ws.transport.http.client.HttpTransportPipe.dump", "true");





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

                List<Map<String, Object>> usuariosCombo = new ArrayList<>();


                for (String n : nicks) {
                    DtUsuario u = null;
                    String tipo;
                    String imagen = null;

                    // Intentar obtener como proponente primero
                    try {
                        DtProponente prop = ICU.devolverProponentePorNickname(n);
                        tipo = "Proponente";
                        u = prop;
                        imagen = prop.getImagen(); // Obtener imagen del proponente
                    } catch (Exception ex) {
                        // No es proponente, intentar como colaborador
                        try {
                            DtColaborador colab = ICU.devolverColaboradorPorNickname(n);
                            tipo = "Colaborador";
                            u = colab;
                            imagen = colab.getImagen(); // Obtener imagen del colaborador
                        } catch (Exception ex2) {
                            // Si no es ni proponente ni colaborador, usar getDTUsuario como fallback
                            u = ICU.getDTUsuario(n);
                            tipo = "Usuario";
                            if (u != null) {
                                imagen = u.getImagen();
                            }
                        }
                    }

                    if (u == null) continue;

                    Map<String, Object> row = new HashMap<>();
                    Long id = u.getId();
                    row.put("id", id != null ? id : 0L);
                    row.put("nick", u.getNickname());
                    row.put("imagen", imagen); // Usar la imagen obtenida específicamente
                    row.put("nombre", u.getNombre());
                    row.put("apellido", u.getApellido());
                    row.put("tipo", tipo);
                    usuariosCombo.add(row);
                }

                usuariosCombo.sort(Comparator.comparingLong(m -> {
                    Object idObj = m.get("id");
                    if (idObj == null) return 0L;
                    if (idObj instanceof Long) return (Long) idObj;
                    return 0L;
                }));

                // Seteo la lista enriquecida para el JSP
                req.setAttribute("usuariosCombo", usuariosCombo);

            } catch (Exception e) {
                req.setAttribute("error", "No se pudo listar usuarios: " + e.getMessage());
            }

            // Establecer atributos del usuario actual para el menú lateral
            HttpSession ses = req.getSession(false);
            DtUsuario actual = (ses != null) ? (DtUsuario) ses.getAttribute("usuarioLogueado") : null;

            boolean esProponenteActual = false;
            boolean esColaboradorActual = false;
            if (actual != null) {
                try {
                    ICU.devolverProponentePorNickname(actual.getNickname());
                    esProponenteActual = true;
                } catch (Exception e) {
                    esProponenteActual = false;
                }

                try {
                    ICU.devolverColaboradorPorNickname(actual.getNickname());
                    esColaboradorActual = true;
                } catch (Exception e) {
                    esColaboradorActual = false;
                }
            }
            req.setAttribute("esProponente", esProponenteActual);
            req.setAttribute("esColaborador", esColaboradorActual);

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
                } catch (Exception ignore) { /* no es proponente */ }

                if (esProp) siguiendoProponentes.add(s);
                else        siguiendoColaboradores.add(s);
            }

            // <-- 2: Armo lista de seguidores -->

            ListaStrings nicks2WS = ICU.devolverUsuariosSeguidores(nick);
            List<String> followers = nicks2WS.getItem();


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
            List<culturarte.servicios.cliente.usuario.DtPropuesta> publicadasNoIngresada = new ArrayList<>();
            List<culturarte.servicios.cliente.usuario.DtPropuesta> creadasIngresadas = new ArrayList<>();
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
            Set<String> proponentesEliminados = new HashSet<>();
            try {
                ListaDTProponente listaEliminados = ICU.devolverProponentesEliminados();
                if (listaEliminados != null && listaEliminados.getProponente() != null) {
                    for (DtProponente propEliminado : listaEliminados.getProponente()) {
                        if (propEliminado != null && propEliminado.getNickname() != null) {
                            proponentesEliminados.add(propEliminado.getNickname());
                        }
                    }
                }
            } catch (Exception e) {
            }

            List<culturarte.servicios.cliente.usuario.DtPropuesta> colaboradas = new ArrayList<>();
            List<DtColaboracion> misColaboraciones = new ArrayList<>();
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                for (DtColaboracion c : colaborador.getColaboraciones()) {
                    if (c.getPropuesta() != null) {
                        culturarte.servicios.cliente.usuario.DtPropuesta prop = c.getPropuesta();
                        if (prop.getDTProponente() != null && prop.getDTProponente().getNickname() != null) {
                            String nicknameProponente = prop.getDTProponente().getNickname();
                            if (!proponentesEliminados.contains(nicknameProponente)) {
                                colaboradas.add(prop);
                                misColaboraciones.add(c);
                            }
                        } else {
                            colaboradas.add(prop);
                            misColaboraciones.add(c);
                        }
                    }
                }
            }

            boolean loSigo = false;
            if (actual != null && usuarioConsultado != null) {
                ListaStrings usuariosWS = ICU.devolverUsuariosSeguidos(actual.getNickname());
                List<String> usuariosSeguidos  = usuariosWS.getItem();

                loSigo = usuariosSeguidos.contains(usuarioConsultado.getNickname());
            }
            req.setAttribute("loSigo", loSigo);

            String bio = null;
            String sitioWeb = null;
            if (proponente != null) {
                bio = proponente.getBio();
                sitioWeb = proponente.getSitioWeb();
            }
            req.setAttribute("bio", bio);
            req.setAttribute("sitioWeb", sitioWeb);


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

            // Atributos del usuario CONSULTADO (para mostrar información del perfil)
            req.setAttribute("esProponenteC", proponente != null);
            req.setAttribute("esColaboradorC", colaborador != null);

            // Atributos del usuario ACTUAL logueado (para el menú lateral)
            boolean esProponenteActual = false;
            boolean esColaboradorActual = false;
            if (actual != null) {
                try {
                    ICU.devolverProponentePorNickname(actual.getNickname());
                    esProponenteActual = true;
                } catch (Exception e) {
                    esProponenteActual = false;
                }

                try {
                    ICU.devolverColaboradorPorNickname(actual.getNickname());
                    esColaboradorActual = true;
                } catch (Exception e) {
                    esColaboradorActual = false;
                }
            }
            req.setAttribute("esProponente", esProponenteActual);
            req.setAttribute("esColaborador", esColaboradorActual);


            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al consultar perfil: " + e.getMessage());
            req.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(req, resp);
        }
    }

}