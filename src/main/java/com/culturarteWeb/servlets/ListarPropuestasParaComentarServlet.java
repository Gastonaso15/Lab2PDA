/*
package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/listarPropuestasParaComentar")
public class ListarPropuestasParaComentarServlet extends HttpServlet {
    private IPropuestaControllerWS IPC;

    @Override
    public void init() throws ServletException {
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DtUsuario usuario = (DtUsuario) session.getAttribute("usuarioLogueado");
        
        try {
            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            List<DtPropuesta> propuestasParaComentar = new ArrayList<>();

            for (DtPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() == DtEstadoPropuesta.FINANCIADA) {
                    boolean haColaborado = false;
                    if (propuesta.getColaboraciones() != null) {
                        for (DtColaboracion colaboracion : propuesta.getColaboraciones()) {
                            if (colaboracion.getColaborador().getNickname().equals(usuario.getNickname())) {
                                haColaborado = true;
                                break;
                            }
                        }
                    }
                    boolean yaComento = false;
                    String claveComentario = usuario.getNickname() + "_" + propuesta.getTitulo();

                    HttpSession sessionComentarios = request.getSession(false);
                    if (sessionComentarios != null) {
                        java.util.Set<String> comentariosExistentes = (java.util.Set<String>) sessionComentarios.getAttribute("comentariosAgregados");
                        if (comentariosExistentes != null && comentariosExistentes.contains(claveComentario)) {
                            yaComento = true;
                        }
                    }
                    
                    if (haColaborado && !yaComento) {
                        propuestasParaComentar.add(propuesta);
                    }
                }
            }
            
            request.setAttribute("propuestasParaComentar", propuestasParaComentar);
            request.setAttribute("usuario", usuario);
            request.getRequestDispatcher("/listaPropuestasParaComentar.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar las propuestas: " + e.getMessage());
            request.getRequestDispatcher("/listaPropuestasParaComentar.jsp").forward(request, response);
        }
    }
}
*/