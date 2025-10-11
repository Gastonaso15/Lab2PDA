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

@WebServlet("/agregarComentario")
public class AgregarComentarioServlet extends HttpServlet {
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar que el usuario esté logueado
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DTUsuario usuario = (DTUsuario) session.getAttribute("usuarioLogueado");
        String tituloPropuesta = request.getParameter("tituloPropuesta");
        String comentario = request.getParameter("comentario");
        
        // Validaciones
        if (tituloPropuesta == null || tituloPropuesta.trim().isEmpty()) {
            request.setAttribute("error", "Título de propuesta no especificado");
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
            return;
        }
        
        if (comentario == null || comentario.trim().isEmpty()) {
            request.setAttribute("error", "El comentario no puede estar vacío");
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
            return;
        }
        
        if (comentario.trim().length() < 10) {
            request.setAttribute("error", "El comentario debe tener al menos 10 caracteres");
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
            return;
        }
        
        try {
            // Buscar la propuesta
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
            
            // Verificar que la propuesta esté financiada
            if (propuesta.getEstadoActual() != DTEstadoPropuesta.FINANCIADA) {
                request.setAttribute("error", "Esta propuesta no está financiada");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }
            
            // Verificar que el usuario haya colaborado
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
            
            // TODO: Aquí se implementaría la lógica real para agregar el comentario
            // Por ahora simulamos que se agregó exitosamente
            System.out.println("Comentario agregado por " + usuario.getNickname() + 
                             " para propuesta " + propuesta.getTitulo() + ": " + comentario);
            
            // Mostrar mensaje de éxito y redirigir
            request.setAttribute("mensajeExito", 
                "¡Comentario agregado exitosamente! Tu comentario ha sido registrado para la propuesta '" + 
                propuesta.getTitulo() + "'.");
            
            request.getRequestDispatcher("/exitoComentario.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al agregar el comentario: " + e.getMessage());
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
        }
    }
}
