package com.culturarteWeb.servlets;

import culturarte.logica.manejadores.PropuestaManejador;
import culturarte.logica.modelos.Propuesta;
import culturarte.logica.modelos.EstadoPropuesta;
import culturarte.logica.DTs.DTPropuesta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/cancelarPropuesta")
public class CancelarPropuestaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String nickname = (String) session.getAttribute("usuario");

        // 2. Obtener propuestas financiadas del proponente
        PropuestaManejador pm = PropuestaManejador.getInstance();
        List<DTPropuesta> propuestasFinanciadas = pm.obtenerTodasLasPropuestas()
                .stream()
                .filter(p -> p.getDTProponente() != null
                        && nickname.equals(p.getDTProponente().getNickname())
                        && p.getEstadoActual() != null
                        && "FINANCIADA".equals(p.getEstadoActual().name()))
                .collect(Collectors.toList());

        // 3. Enviar al JSP
        request.setAttribute("propuestas", propuestasFinanciadas);
        request.getRequestDispatcher("/cancelarPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String nickname = (String) session.getAttribute("usuario");
        String titulo = request.getParameter("titulo");

        PropuestaManejador pm = PropuestaManejador.getInstance();
        Propuesta propuesta = pm.obtenerPropuestaPorTitulo(titulo);

        String mensaje;
        if (propuesta != null
                && propuesta.getProponente() != null
                && nickname.equals(propuesta.getProponente().getNickname())
                && propuesta.getEstadoActual() == EstadoPropuesta.FINANCIADA) {

            // Cambiar estado y registrar fecha
            propuesta.setEstadoActual(EstadoPropuesta.CANCELADA);
            propuesta.agregarPropuestaEstado(new culturarte.logica.modelos.PropuestaEstado(propuesta, EstadoPropuesta.CANCELADA, LocalDate.now()));
            pm.actualizarPropuesta(propuesta);

            mensaje = "Propuesta '" + titulo + "' cancelada correctamente.";
        } else {
            mensaje = "No se pudo cancelar la propuesta seleccionada.";
        }

        // Volver a mostrar lista actualizada
        List<DTPropuesta> propuestasFinanciadas = pm.obtenerTodasLasPropuestas()
                .stream()
                .filter(p -> p.getDTProponente() != null
                        && nickname.equals(p.getDTProponente().getNickname())
                        && p.getEstadoActual() != null
                        && "FINANCIADA".equals(p.getEstadoActual().name()))
                .collect(Collectors.toList());

        request.setAttribute("propuestas", propuestasFinanciadas);
        request.setAttribute("mensaje", mensaje);
        request.getRequestDispatcher("/cancelarPropuesta.jsp").forward(request, response);
    }
}
