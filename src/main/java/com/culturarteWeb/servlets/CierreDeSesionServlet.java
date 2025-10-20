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
        HttpSession session = request.getSession(false);

        if (session != null) {
            System.out.println(">> Cerrando sesión del usuario: " + session.getAttribute("usuario"));
            session.invalidate();
        } else {
            System.out.println(">> No había sesión activa al intentar cerrar sesión.");
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "0");

        response.sendRedirect(request.getContextPath() + "/cierreDeSesion.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}