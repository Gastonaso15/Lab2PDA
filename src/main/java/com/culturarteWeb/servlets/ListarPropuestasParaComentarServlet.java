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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/listarPropuestasParaComentar")
public class ListarPropuestasParaComentarServlet extends HttpServlet {
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar que el usuario esté logueado
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion");
            return;
        }

        DTUsuario usuario = (DTUsuario) session.getAttribute("usuarioLogueado");
        
        try {
            // Obtener todas las propuestas
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasParaComentar = new ArrayList<>();
            
            // Filtrar propuestas financiadas donde el usuario colaboró y no ha comentado
            for (DTPropuesta propuesta : todasLasPropuestas) {
                // Verificar que esté en estado FINANCIADA
                if (propuesta.getEstadoActual() == DTEstadoPropuesta.FINANCIADA) {
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
                    
                    // Verificar que no haya comentado (asumimos que no hay comentarios implementados aún)
                    // TODO: Implementar verificación de comentarios cuando esté disponible
                    boolean yaComento = false; // Por ahora siempre false
                    
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
