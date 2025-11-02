/*
package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/seguimientoDeUsuario")
public class SeguimientoDeUsuarioServlet extends HttpServlet {
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        try {;
            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        DtUsuario usuarioActual = (DtUsuario) sesion.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickSeguidor = usuarioActual.getNickname();
        String nickSeguido = request.getParameter("seguido");

        try{
            if(ICU.usuarioUnoYaSigueUsuarioDos(nickSeguidor, nickSeguido)){
                ICU.dejarDeSeguirUsuario(nickSeguidor, nickSeguido);
            }else{
                ICU.seguirUsuario(nickSeguidor,nickSeguido);
            }
            response.sendRedirect(request.getContextPath() + "/consultaPerfilUsuario?nick=" + nickSeguido);
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/consultaPerfilUsuario.jsp").forward(request, response);

        }
    }
}
*/
