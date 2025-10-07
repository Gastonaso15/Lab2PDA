package com.culturarteWeb.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/cierreSesion")
public class CierreDeSesionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false); // false: no crear si no existe
        if (session != null) {
            session.invalidate();
        }

        request.setAttribute("mensaje", "Has cerrado sesión correctamente.");

        request.getRequestDispatcher("/WEB-INF/cierreDeSesion.jsp").forward(request, response);


    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
