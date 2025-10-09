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

        // 1. Obtener la sesión sin crear una nueva si no existe
        HttpSession session = request.getSession(false);

        if (session != null) {
            System.out.println(">> Cerrando sesión del usuario: " + session.getAttribute("usuario"));
            // 2. Invalida la sesión actual: ¡Este es el paso clave!
            session.invalidate();
        } else {
            System.out.println(">> No había sesión activa al intentar cerrar sesión.");
        }

        // 3. Configurar encabezados para prevenir el caché del navegador
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "0");

        // 4. Redirigir al JSP de confirmación
        // Se usa sendRedirect para forzar una nueva petición al JSP,
        // asumiendo que está en la raíz del contexto de la aplicación (/webapp).
        response.sendRedirect(request.getContextPath() + "/cierreDeSesion.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}