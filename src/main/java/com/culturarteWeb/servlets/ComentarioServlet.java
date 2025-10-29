package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.DTs.DTColaboracion;
import culturarte.logica.DTs.DTEstadoPropuesta;
import culturarte.logica.DTs.DTComentario;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.PropuestaController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/comentario")
public class ComentarioServlet extends HttpServlet {
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        mostrarFormularioComentario(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        procesarComentario(request, response);
    }

    private void mostrarFormularioComentario(HttpServletRequest request, HttpServletResponse response) 
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
            ValidationResult validation = validarPropuestaParaComentario(tituloPropuesta, usuario);
            
            if (!validation.isValid()) {
                request.setAttribute("error", validation.getErrorMessage());
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }
            DTPropuesta propuesta = validation.getPropuesta();
            List<DTComentario> comentariosExistentes = IPC.obtenerComentariosPropuesta(propuesta.getTitulo());
            boolean yaComento = false;
            for (DTComentario comentarioExistente : comentariosExistentes) {
                if (comentarioExistente.getUsuarioNickname() != null && 
                    comentarioExistente.getUsuarioNickname().equals(usuario.getNickname())) {
                    yaComento = true;
                    break;
                }
            }
            
            if (yaComento) {
                request.setAttribute("error", "Ya has comentado esta propuesta anteriormente");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }
            
            request.setAttribute("propuesta", propuesta);
            request.setAttribute("usuario", usuario);
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar el formulario: " + e.getMessage());
            request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
        }
    }

    private void procesarComentario(HttpServletRequest request, HttpServletResponse response) 
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
            ValidationResult validation = validarPropuestaParaComentario(tituloPropuesta, usuario);
            
            if (!validation.isValid()) {
                request.setAttribute("error", validation.getErrorMessage());
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }
            
            DTPropuesta propuesta = validation.getPropuesta();
            
            List<DTComentario> comentariosExistentes = IPC.obtenerComentariosPropuesta(propuesta.getTitulo());
            boolean yaComento = false;
            for (DTComentario comentarioExistente : comentariosExistentes) {
                if (comentarioExistente.getUsuarioNickname() != null && 
                    comentarioExistente.getUsuarioNickname().equals(usuario.getNickname())) {
                    yaComento = true;
                    break;
                }
            }
            
            if (yaComento) {
                request.setAttribute("error", "Ya has comentado esta propuesta anteriormente");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }

            String claveComentario = usuario.getNickname() + "_" + propuesta.getTitulo();
            java.util.Set<String> comentariosEnSesion = (java.util.Set<String>) session.getAttribute("comentariosAgregados");
            if (comentariosEnSesion == null) {
                comentariosEnSesion = new java.util.HashSet<>();
            }
            
            if (comentariosEnSesion.contains(claveComentario)) {
                request.setAttribute("error", "Ya has comentado esta propuesta anteriormente");
                request.getRequestDispatcher("/formularioComentario.jsp").forward(request, response);
                return;
            }

            IPC.agregarComentario(propuesta.getTitulo(), usuario.getNickname(), comentario);

            comentariosEnSesion.add(claveComentario);
            session.setAttribute("comentariosAgregados", comentariosEnSesion);

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


    private ValidationResult validarPropuestaParaComentario(String tituloPropuesta, DTUsuario usuario) {
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
                return new ValidationResult(false, "Propuesta no encontrada", null);
            }

            if (propuesta.getEstadoActual() != DTEstadoPropuesta.FINANCIADA) {
                return new ValidationResult(false, "Esta propuesta no está financiada", null);
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
                return new ValidationResult(false, "No puedes comentar esta propuesta porque no colaboraste con ella", null);
            }
            
            return new ValidationResult(true, null, propuesta);
            
        } catch (Exception e) {
            return new ValidationResult(false, "Error al validar propuesta: " + e.getMessage(), null);
        }
    }

    private static class ValidationResult {
        private final boolean valid;
        private final String errorMessage;
        private final DTPropuesta propuesta;

        public ValidationResult(boolean valid, String errorMessage, DTPropuesta propuesta) {
            this.valid = valid;
            this.errorMessage = errorMessage;
            this.propuesta = propuesta;
        }

        public boolean isValid() {
            return valid;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public DTPropuesta getPropuesta() {
            return propuesta;
        }
    }
}
