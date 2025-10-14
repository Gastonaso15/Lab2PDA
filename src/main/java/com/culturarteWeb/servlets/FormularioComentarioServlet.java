package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.DTs.DTColaboracion;
import culturarte.logica.DTs.DTEstadoPropuesta;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/formularioComentario")
public class FormularioComentarioServlet extends HttpServlet {
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DTUsuario usuario = (DTUsuario) session.getAttribute("usuarioLogueado");
        String tituloPropuesta = request.getParameter("titulo");
        
        if (tituloPropuesta == null || tituloPropuesta.trim().isEmpty()) {
            request.setAttribute("error", "Título de propuesta no especificado");
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
            return;
        }
        
        try {
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            DTPropuesta propuesta = null;
            
            for (DTPropuesta p : todasLasPropuestas) {
                if (p.getTitulo().equals(tituloPropuesta)) {
                    propuesta = p;
                    break;
                }
            }
            
            if (propuesta == null) {
                request.setAttribute("error", "Propuesta no encontrada");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }

            if (propuesta.getEstadoActual() != DTEstadoPropuesta.FINANCIADA) {
                request.setAttribute("error", "Esta propuesta no está financiada");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }

            boolean haColaborado = false;
            if (propuesta.getColaboraciones() != null) {
                for (DTColaboracion colaboracion : propuesta.getColaboraciones()) {
                    if (colaboracion.getColaborador().getNickname().equals(usuario.getNickname())) {
                        haColaborado = true;
                        break;
                    }
                }
            }
            
            if (!haColaborado) {
                request.setAttribute("error", "No puedes comentar esta propuesta porque no colaboraste con ella");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }
            
            String claveComentario = usuario.getNickname() + "_" + propuesta.getTitulo();
            if (session != null) {
                @SuppressWarnings("unchecked")
                java.util.Set<String> comentariosExistentes = (java.util.Set<String>) session.getAttribute("comentariosAgregados");
                if (comentariosExistentes != null && comentariosExistentes.contains(claveComentario)) {
                    request.setAttribute("error", "Ya has comentado esta propuesta anteriormente");
                    request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                    return;
                }
            }
            
            request.setAttribute("propuesta", propuesta);
            request.setAttribute("usuario", usuario);
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar el formulario: " + e.getMessage());
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
        }
    }
}
