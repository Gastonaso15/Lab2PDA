/*
package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.DtPropuesta;
import culturarte.servicios.cliente.propuestas.IPropuestaControllerWS;
import culturarte.servicios.cliente.propuestas.ListaDTPropuesta;
import culturarte.servicios.cliente.propuestas.PropuestaWSEndpointService;
import culturarte.servicios.cliente.propuestas.DtUsuario;
import culturarte.servicios.cliente.usuario.DtProponente;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/extenderFinanciacion")

public class ExtenderFinanciacionServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //averiguo si es proponente o no
        boolean esProponente = false;
        DtProponente userProponente = null;
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuarioLogueado") != null) {
            DtUsuario user = (DtUsuario) session.getAttribute("usuarioLogueado");
            try {
                userProponente= ICU.devolverProponentePorNickname(user.getNickname());
                esProponente = true;
            } catch (Exception e) {
                esProponente = false;
            }
        }

        ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
        List<DtPropuesta> propuestas = propuestasWS.getPropuesta();

        List<DtPropuesta> propuestasActivas = new ArrayList<>();

        if (!esProponente || userProponente == null) {
            request.setAttribute("error", "Solo los proponentes pueden extender la financiacion de sus propuestas.");
            request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
            return;
        }

        for (DtPropuesta p : propuestas) {
            if(p.getDTProponente().getNickname().equals(userProponente.getNickname())) {
                if ((p.getEstadoActual().toString().equals("EN_FINANCIACION")
                        || p.getEstadoActual().toString().equals("PUBLICADA"))) {
                    boolean activa = p.getFechaPublicacion().atStartOfDay()
                            .plusMonths(1)
                            .isAfter(LocalDateTime.now());
                    if (activa)
                        propuestasActivas.add(p);
                }
            }
        }

        request.setAttribute("propuestas", propuestasActivas);
        request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String propuestaSeleccionada = request.getParameter("propuestas");

        try {

            //<-- Obtengo el usuario actual para poder trabajar con él -->
            HttpSession session = request.getSession(false);
            session.getAttribute("usuarioLogueado"); //esto funciona porque está codeado en InicioDeSesionServlet
            DtUsuario user = (DtUsuario) session.getAttribute("usuarioLogueado");



            //<-- Modificaciones para funcionamiento de AJAX -->
                // Es una llamada AJAX desde el detalle?
            boolean esAjax = "1".equals(request.getParameter("ajax"));
                // Recupero el titulo como me lo manda Ajax
            String tituloSeleccionado = request.getParameter("titulo");
            if (tituloSeleccionado == null || tituloSeleccionado.isBlank()) {
                tituloSeleccionado = request.getParameter("propuestas");
            }
            if (esAjax) {
                IPC.extenderFinanciacion(user, tituloSeleccionado);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Financiación extendida correctamente.");
                return;
            }else {
                IPC.extenderFinanciacion(user, propuestaSeleccionada);
            }
            request.setAttribute("mensaje", "La financiación de la propuesta ha sido extendida exitosamente.");
        } catch (Exception e) {
            e.printStackTrace(); // <-- imprime el error completo en la consola del servidor
        }
        doGet(request, response);
    }
}
*/