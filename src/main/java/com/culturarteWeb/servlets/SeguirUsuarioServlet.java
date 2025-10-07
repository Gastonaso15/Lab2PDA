package com.culturarteWeb.servlets;

import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IUsuarioController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/seguirUsuario")
public class SeguirUsuarioServlet extends HttpServlet {
    private IUsuarioController IUC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IUC = fabrica.getIUsuarioController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String nickSeguido = request.getParameter("seguido");
        String nickSeguidor = request.getParameter("seguidor");

        try{
            IUC.seguirUsuario(nickSeguidor,nickSeguido);
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            //request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
        }

    }
}
