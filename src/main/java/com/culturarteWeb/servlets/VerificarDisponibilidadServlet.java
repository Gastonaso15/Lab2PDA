package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.ListaStrings;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/verificarDisponibilidad")
public class VerificarDisponibilidadServlet extends HttpServlet {

    private IUsuarioControllerWS IUC;

    @Override
    public void init() throws ServletException {
        try {
            UsuarioWSEndpointService servicio = new UsuarioWSEndpointService();
            IUC = servicio.getUsuarioWSEndpointPort();
        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String tipo = request.getParameter("tipo");
        String valor = request.getParameter("valor");

        if (tipo == null || valor == null || valor.trim().isEmpty()) {
            out.print("{\"disponible\": false, \"mensaje\": \"Valor inválido\"}");
            out.flush();
            return;
        }

        try {
            boolean disponible = false;
            String mensaje = "";

            if ("nickname".equals(tipo)) {
                disponible = verificarNicknameDisponible(valor.trim());
                if (disponible) {
                    mensaje = "Nickname disponible";
                } else {
                    mensaje = "Este nickname ya está en uso";
                }
            } else if ("email".equals(tipo)) {
                disponible = verificarEmailDisponible(valor.trim());
                if (disponible) {
                    mensaje = "Email disponible";
                } else {
                    mensaje = "Este email ya está en uso";
                }
            } else {
                out.print("{\"disponible\": false, \"mensaje\": \"Tipo de verificación inválido\"}");
                out.flush();
                return;
            }

            out.print("{\"disponible\": " + disponible + ", \"mensaje\": \"" + mensaje + "\"}");
            out.flush();

        } catch (Exception e) {
            out.print("{\"disponible\": false, \"mensaje\": \"Error al verificar disponibilidad: " + 
                     e.getMessage().replace("\"", "\\\"") + "\"}");
            out.flush();
        }
    }

    private boolean verificarNicknameDisponible(String nickname) {
        try {
            DtUsuario usuario = IUC.getDTUsuario(nickname);
            if (usuario != null && usuario.getNickname() != null && 
                usuario.getNickname().trim().equalsIgnoreCase(nickname.trim())) {
                return false;
            }
            return true;
        } catch (Exception e) {
            return true;
        }
    }

    private boolean verificarEmailDisponible(String email) {
        try {
            ListaStrings nicksWS = IUC.devolverNicknamesUsuarios();
            List<String> nicks = nicksWS.getItem();
            
            for (String nick : nicks) {
                try {
                    DtUsuario usuario = IUC.getDTUsuario(nick);
                    if (usuario != null && usuario.getCorreo() != null && 
                        usuario.getCorreo().trim().equalsIgnoreCase(email.trim())) {
                        return false;
                    }
                } catch (Exception e) {
                    continue;
                }
            }
            return true;
        } catch (Exception e) {
            return true;
        }
    }
}

