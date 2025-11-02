package com.culturarteWeb.servlets;


import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.lang.Exception;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import static java.net.URLEncoder.encode;

@WebServlet("/cancelarPropuesta")
public class CancelarPropuestaServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickname = usuarioActual.getNickname();

        if (session.getAttribute("mensaje") != null) {
            request.setAttribute("mensaje", session.getAttribute("mensaje"));
            session.removeAttribute("mensaje");
        }


        ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
        List<DtPropuesta> propuestasFinanciadas = propuestasWS.getPropuesta()
                .stream()
                .filter(p -> p.getDTProponente() != null
                        && nickname.equals(p.getDTProponente().getNickname())
                        && p.getEstadoActual() != null
                        && "FINANCIADA".equalsIgnoreCase(p.getEstadoActual().name())) // Usar equalsIgnoreCase es más robusto
                .collect(Collectors.toList());

        request.setAttribute("propuestas", propuestasFinanciadas);
        request.getRequestDispatcher("/cancelarPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickname = usuarioActual.getNickname();

        String titulo = request.getParameter("titulo");
        String source = request.getParameter("source"); // Para saber de dónde viene la petición

        if (nickname == null || titulo == null || titulo.trim().isEmpty()) {
            session.setAttribute("mensaje", "Error: No se pudo procesar la solicitud. Faltan datos.");
            response.sendRedirect(request.getContextPath() + "/principal"); // Redirigir a una página segura
            return;
        }

        DtPropuesta propuesta = IPC.getDTPropuesta(titulo);
        String mensaje;

        if (propuesta != null
                && propuesta.getDTProponente().getNickname() != null
                && nickname.equals(propuesta.getDTProponente().getNickname())
                && propuesta.getEstadoActual() == DtEstadoPropuesta.FINANCIADA) {


            propuesta.setEstadoActual(DtEstadoPropuesta.CANCELADA);

            DtPropuestaEstado propEstado = new DtPropuestaEstado();
            propEstado.setPropuesta(propuesta);
            propEstado.setEstado(DtEstadoPropuesta.CANCELADA);
            propEstado.setFechaCambio(WSFechaPropuesta.toWSLocalDate(java.time.LocalDate.now()));

            propuesta.getHistorial().add(propEstado);

            IPC.modificarHistorialYEstadoPropuesta(propuesta);

            mensaje = "Propuesta '" + titulo + "' cancelada correctamente.";
        } else {
            mensaje = "Error: No se pudo cancelar la propuesta. Puede que no te pertenezca o su estado no sea 'Financiada'.";
        }

        session.setAttribute("mensaje", mensaje);

        if ("detail".equals(source)) {
            response.sendRedirect(request.getContextPath() + "/consultaPropuesta?accion=detalle&titulo=" + encode(titulo, "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/cancelarPropuesta");
        }
    }
}