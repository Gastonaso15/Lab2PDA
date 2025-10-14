package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/consultaPerfilUsuario")
public class ConsultaPerfilUsuarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nick = request.getParameter("nick");
        if (nick == null) nick = "UsuarioPrueba";

        DTUsuario usuario = new DTUsuario();
        usuario.setNickname(nick);

        request.setAttribute("usuarioConsultado", usuario);
        request.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(request, response);
    }
}
