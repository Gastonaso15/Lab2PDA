package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/bajaProponente")
public class BajaProponenteServlet extends HttpServlet {

    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        try {
            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();
        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");

        try {
            ICU.devolverProponentePorNickname(usuarioActual.getNickname());
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/bajaProponente.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");
        String confirmacion = request.getParameter("confirmacion");

        if (!"CONFIRMAR".equals(confirmacion)) {
            request.setAttribute("error", "Debe escribir CONFIRMAR para darse de baja");
            request.getRequestDispatcher("/bajaProponente.jsp").forward(request, response);
            return;
        }

        try {
            ICU.bajaProponente(usuarioActual.getNickname());

            session.invalidate();

            request.setAttribute("mensaje", "Tu cuenta ha sido eliminada exitosamente.");
            request.getRequestDispatcher("/bajaCompletada.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al eliminar la cuenta: " + e.getMessage());
            request.getRequestDispatcher("/bajaProponente.jsp").forward(request, response);
        }
    }
}