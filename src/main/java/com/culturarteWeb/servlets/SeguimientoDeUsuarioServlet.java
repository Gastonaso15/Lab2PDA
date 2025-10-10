package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IUsuarioController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/seguimientoDeUsuario")
public class SeguimientoDeUsuarioServlet extends HttpServlet {
    private IUsuarioController IUC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IUC = fabrica.getIUsuarioController();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        DTUsuario usuarioActual = (DTUsuario) sesion.getAttribute("usuario");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickSeguidor = usuarioActual.getNickname();
        String nickSeguido = request.getParameter("seguido");

        try{
            if(IUC.UsuarioUnoYaSigueUsuarioDos(nickSeguidor, nickSeguido)){
                IUC.dejarDeSeguirUsuario(nickSeguidor, nickSeguido);
            }else{
                IUC.seguirUsuario(nickSeguidor,nickSeguido);
            }
            response.sendRedirect(request.getContextPath() + "/consultaPerfilUsuario?nick=" + nickSeguido);
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(request, response);

        }
    }
}