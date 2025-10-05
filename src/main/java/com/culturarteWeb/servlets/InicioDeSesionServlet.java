package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.ISesionController;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/inicioDeSesion")
public class InicioDeSesionServlet extends HttpServlet {

    private ISesionController ICS;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        ICS = fabrica.getISesionController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nickname = request.getParameter("usuario");
        String password = request.getParameter("password");

        try {
            DTUsuario usuario = ICS.login(nickname, password);
            if (usuario != null) {
                HttpSession old = request.getSession(false);
                if (old != null) old.invalidate();

                HttpSession session = request.getSession(true);
                session.setAttribute("usuarioLogueado", usuario);

                response.sendRedirect(request.getContextPath() + "/inicio");
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
