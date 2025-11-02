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

import static java.net.URLEncoder.encode;

@WebServlet("/marcarPropuestaFavorita")
public class MarcarPropuestaFavorita extends HttpServlet {
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession sesion = request.getSession(false);
        DtUsuario usuarioActual = (DtUsuario) sesion.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        String nickUsuario = usuarioActual.getNickname();
        String tituloPropuesta = request.getParameter("titulo");

        try{
            if(ICU.usuarioYaTienePropuestaFavorita(nickUsuario, tituloPropuesta)){
                ICU.quitarPropuestaFavorita(nickUsuario, tituloPropuesta);
            }else{
                ICU.marcarPropuestaFavorita(nickUsuario,tituloPropuesta);
            }
            response.sendRedirect(request.getContextPath() + "/consultaPropuesta?accion=detalle&titulo=" + encode(tituloPropuesta, "UTF-8"));

        }catch(Exception e){
            response.sendRedirect(request.getContextPath() + "/consultaPropuesta?accion=detalle&titulo=" + encode(tituloPropuesta, "UTF-8") + "&error=" + encode(e.getMessage(), "UTF-8"));
        }
    }

}
*/
