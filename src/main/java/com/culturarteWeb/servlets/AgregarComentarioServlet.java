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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DTUsuario usuario = (DTUsuario) session.getAttribute("usuarioLogueado");
        String tituloPropuesta = request.getParameter("tituloPropuesta");
        String comentario = request.getParameter("comentario");

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
            java.util.Set<String> comentariosExistentes = (java.util.Set<String>) session.getAttribute("comentariosAgregados");
            if (comentariosExistentes == null) {
                comentariosExistentes = new java.util.HashSet<>();
            }
            

            if (comentariosExistentes.contains(claveComentario)) {
                request.setAttribute("error", "Ya has comentado esta propuesta anteriormente");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }
            
            comentariosExistentes.add(claveComentario);
            session.setAttribute("comentariosAgregados", comentariosExistentes);

            System.out.println("Comentario agregado exitosamente:");
            System.out.println("- Usuario: " + usuario.getNickname());
            System.out.println("- Propuesta: " + propuesta.getTitulo());
            System.out.println("- Comentario: " + comentario);
            System.out.println("- Fecha: " + java.time.LocalDateTime.now());

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
