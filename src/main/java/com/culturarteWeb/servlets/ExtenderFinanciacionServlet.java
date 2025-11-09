package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.DtPropuesta;
import culturarte.servicios.cliente.propuestas.IPropuestaControllerWS;
import culturarte.servicios.cliente.propuestas.ListaDTPropuesta;
import culturarte.servicios.cliente.propuestas.PropuestaWSEndpointService;
import culturarte.servicios.cliente.usuario.DtUsuario;

import culturarte.servicios.cliente.usuario.DtProponente;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
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

        boolean esProponente = false;
        DtProponente userProponente = null;

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            request.setAttribute("error", "Debes iniciar sesión para extender la financiación.");
            request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
            return;
        }

        DtUsuario user = (DtUsuario) session.getAttribute("usuarioLogueado");
        try {
            userProponente = ICU.devolverProponentePorNickname(user.getNickname());
            esProponente = (userProponente != null);
        } catch (Exception ignored) {
            esProponente = false;
        }

        if (!esProponente) {
            request.setAttribute("error", "Solo los proponentes pueden extender la financiación de sus propuestas.");
            request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
            return;
        }

        ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
        List<DtPropuesta> propuestas = (propuestasWS != null) ? propuestasWS.getPropuesta() : List.of();

        List<DtPropuesta> propuestasActivas = new ArrayList<>();
        for (DtPropuesta p : propuestas) {
            if (p.getDTProponente() != null
                    && userProponente.getNickname().equals(p.getDTProponente().getNickname())) {

                String estado = (p.getEstadoActual() != null) ? p.getEstadoActual().toString() : "";
                boolean enVentana = false;
                if (p.getFechaPublicacion() != null) {
                    var fechaPub = WSFechaPropuesta.toJavaLocalDate(p.getFechaPublicacion());
                    enVentana = fechaPub.atStartOfDay().plusMonths(1).isAfter(LocalDateTime.now());
                }
                if (enVentana && ("EN_FINANCIACION".equals(estado) || "PUBLICADA".equals(estado))) {
                    propuestasActivas.add(p);
                }
            }
        }

        request.setAttribute("propuestas", propuestasActivas);
        request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        boolean esAjax = "1".equals(request.getParameter("ajax"));
        String tituloSeleccionado = request.getParameter("titulo");
        if (tituloSeleccionado == null || tituloSeleccionado.isBlank()) {
            tituloSeleccionado = request.getParameter("propuestas");
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            if (esAjax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("No hay sesión activa.");
                return;
            }
            request.setAttribute("error", "Debes iniciar sesión para extender la financiación.");
            doGet(request, response);
            return;
        }

        if (tituloSeleccionado == null || tituloSeleccionado.isBlank()) {
            if (esAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Falta el título de la propuesta.");
                return;
            }
            request.setAttribute("error", "Debes seleccionar una propuesta.");
            doGet(request, response);
            return;
        }


        culturarte.servicios.cliente.usuario.DtUsuario userSesion = (culturarte.servicios.cliente.usuario.DtUsuario) session.getAttribute("usuarioLogueado");
        culturarte.servicios.cliente.propuestas.DtUsuario userWS = new culturarte.servicios.cliente.propuestas.DtUsuario();
        userWS.setNickname(userSesion.getNickname());


        try {

            IPC.extenderFinanciacion(userWS, tituloSeleccionado);

            if (esAjax) {
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Financiación extendida correctamente.");
                return;
            } else {
                request.setAttribute("mensaje", "La financiación de la propuesta ha sido extendida exitosamente.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            String msg = (e.getMessage() != null) ? e.getMessage() : "No se pudo extender la financiación.";
            if (esAjax) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("No se pudo extender la financiación: " + msg);
                return;
            } else {
                request.setAttribute("error", "No se pudo extender la financiación: " + msg);
            }
        }

        doGet(request, response);
    }}