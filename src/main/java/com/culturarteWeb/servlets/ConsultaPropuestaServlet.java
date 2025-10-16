package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.DTs.DTColaboracion;
import culturarte.logica.DTs.DTEstadoPropuesta;
import culturarte.logica.DTs.DTComentario;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;

import culturarte.logica.controladores.IUsuarioController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/consultaPropuesta")
public class ConsultaPropuestaServlet extends HttpServlet {

    private IPropuestaController IPC;
    private IUsuarioController ICU;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
        ICU = fabrica.getIUsuarioController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        if ("detalle".equals(accion)) {
            mostrarDetallePropuesta(request, response);
        } else {
            mostrarListaPropuestas(request, response);
        }
    }
    
    private void mostrarListaPropuestas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasVisibles = new ArrayList<>();
            
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA) {
                    propuestasVisibles.add(propuesta);
                }
            }
            
            request.setAttribute("propuestas", propuestasVisibles);
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar las propuestas: " + e.getMessage());
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
        }
    }
    
    private void mostrarDetallePropuesta(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tituloPropuesta = request.getParameter("titulo");
        
        if (tituloPropuesta == null || tituloPropuesta.trim().isEmpty()) {
            request.setAttribute("error", "Título de propuesta no especificado");
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
            return;
        }
        
        try {
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            DTPropuesta propuestaSeleccionada = null;
            
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (tituloPropuesta.equals(propuesta.getTitulo())) {
                    propuestaSeleccionada = propuesta;
                    break;
                }
            }
            
            if (propuestaSeleccionada == null) {
                request.setAttribute("error", "Propuesta no encontrada");
                request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
                return;
            }
            double montoRecaudado = 0.0;
            List<String> nicknamesColaboradores = new ArrayList<>();
            
            if (propuestaSeleccionada.getColaboraciones() != null) {
                for (DTColaboracion colaboracion : propuestaSeleccionada.getColaboraciones()) {
                    montoRecaudado += colaboracion.getMonto();
                    nicknamesColaboradores.add(colaboracion.getColaborador().getNickname());
                }
            }
            HttpSession sesion = request.getSession(false);
            DTUsuario usuarioActual = null;
            boolean esProponente = false;
            boolean haColaborado = false;
            boolean esFavorita = false;
            
            if (sesion != null && sesion.getAttribute("usuarioLogueado") != null) {
                usuarioActual = (DTUsuario) sesion.getAttribute("usuarioLogueado");
                if (propuestaSeleccionada.getDTProponente() != null && 
                    usuarioActual.getNickname().equals(propuestaSeleccionada.getDTProponente().getNickname())) {
                    esProponente = true;
                }
                if (nicknamesColaboradores.contains(usuarioActual.getNickname())) {
                    haColaborado = true;
                }
                if (ICU.UsuarioYaTienePropuestaFavorita(usuarioActual.getNickname(), propuestaSeleccionada.getTitulo())){
                    esFavorita = true;
                }
            }

            List<DTComentario> comentarios = IPC.obtenerComentariosPropuesta(propuestaSeleccionada.getTitulo());
            request.setAttribute("propuesta", propuestaSeleccionada);
            request.setAttribute("montoRecaudado", montoRecaudado);
            request.setAttribute("nicknamesColaboradores", nicknamesColaboradores);
            request.setAttribute("esProponente", esProponente);
            request.setAttribute("haColaborado", haColaborado);
            request.setAttribute("usuarioActual", usuarioActual);
            request.setAttribute("esFavorita", esFavorita);
            request.setAttribute("comentarios", comentarios);
            
            request.getRequestDispatcher("/detallePropuesta.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la propuesta: " + e.getMessage());
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
        }
    }
}