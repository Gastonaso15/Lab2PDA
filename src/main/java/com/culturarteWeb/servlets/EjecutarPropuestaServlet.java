package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.manejadores.PropuestaManejador;
import culturarte.logica.modelos.Propuesta;
import culturarte.logica.modelos.EstadoPropuesta;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/ejecutarPropuesta")
public class EjecutarPropuestaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        DTUsuario usuarioActual = (DTUsuario) session.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickname = usuarioActual.getNickname();

        if (session.getAttribute("mensaje") != null) {
            request.setAttribute("mensaje", session.getAttribute("mensaje"));
            session.removeAttribute("mensaje");
        }

        PropuestaManejador pm = PropuestaManejador.getInstance();
        List<Propuesta> propuestasFinanciadas = pm.obtenerTodasLasPropuestas()
                .stream()
                .filter(p -> p.getProponente() != null
                        && nickname.equals(p.getProponente())
                        && p.getEstadoActual().toString().equals("FINANCIADA"))
                .map(p -> pm.obtenerPropuestaPorTitulo(p.getTitulo()))
                .filter(p -> p != null)
                .collect(Collectors.toList());

        request.setAttribute("propuestas", propuestasFinanciadas);
        request.getRequestDispatcher("/ejecutarPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        DTUsuario usuarioActual = (DTUsuario) session.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickname = usuarioActual.getNickname();
        String titulo = request.getParameter("titulo");
        String source = request.getParameter("source");

        if (nickname == null || titulo == null || titulo.trim().isEmpty()) {
            session.setAttribute("mensaje", "Error: No se pudo procesar la solicitud. Faltan datos.");
            response.sendRedirect(request.getContextPath() + "/principal");
            return;
        }

        PropuestaManejador pm = PropuestaManejador.getInstance();
        Propuesta propuesta = pm.obtenerPropuestaPorTitulo(titulo);
        String mensaje;

        if (propuesta != null
                && propuesta.getProponente() != null
                && nickname.equals(propuesta.getProponente().getNickname())
                && propuesta.getEstadoActual() == EstadoPropuesta.FINANCIADA) {

            propuesta.agregarPropuestaEstado(new culturarte.logica.modelos.PropuestaEstado(
                propuesta, EstadoPropuesta.FINANCIADA, LocalDate.now()));
            pm.actualizarPropuesta(propuesta);

            mensaje = "Propuesta '" + titulo + "' marcada como ejecutada correctamente.";
        } else {
            mensaje = "Error: No se pudo ejecutar la propuesta. Puede que no te pertenezca o su estado no sea 'Financiada'.";
        }

        session.setAttribute("mensaje", mensaje);

        if ("detail".equals(source)) {
            response.sendRedirect(request.getContextPath() + "/consultaPropuesta?accion=detalle&titulo=" + 
                java.net.URLEncoder.encode(titulo, "UTF-8"));
        } else {
            response.sendRedirect(request.getContextPath() + "/ejecutarPropuesta");
        }
    }
}
