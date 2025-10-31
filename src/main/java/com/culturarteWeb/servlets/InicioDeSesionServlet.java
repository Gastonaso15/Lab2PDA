package com.culturarteWeb.servlets;


import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/inicioDeSesion")
public class InicioDeSesionServlet extends HttpServlet {

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
        request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usuario = request.getParameter("usuario");
        String password = request.getParameter("password");

        try {
            DtUsuario usu = ICU.login(usuario, password);
            if (usu != null) {
                HttpSession anterior = request.getSession(false);
                if (anterior != null) anterior.invalidate();

                HttpSession sesion = request.getSession(true);
                sesion.setAttribute("usuarioLogueado", usu);

                response.sendRedirect(request.getContextPath());
            } else {
                request.setAttribute("error", "Usuario o contraseña incorrectos");
                request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
            }

        } catch (RuntimeException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
        }
    }
}
