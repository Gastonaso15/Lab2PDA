package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.IPropuestaControllerWS;
import culturarte.servicios.cliente.propuestas.PropuestaWSEndpointService;
import culturarte.servicios.cliente.usuario.DtColaboracion;
import culturarte.servicios.cliente.usuario.DtColaborador;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/listarColaboracionesConstancia")
public class ListarColaboracionesConstanciaServlet extends HttpServlet {

    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();
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

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");
        
        try {
            DtColaborador colaborador;
            try {
                colaborador = ICU.devolverColaboradorPorNickname(usuarioActual.getNickname());
            } catch (Exception e) {
                request.setAttribute("error", "Solo los colaboradores pueden solicitar constancias de pago.");
                request.getRequestDispatcher("/listarColaboracionesConstancia.jsp").forward(request, response);
                return;
            }

            List<DtColaboracion> todasLasColaboraciones = new ArrayList<>();
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                todasLasColaboraciones = colaborador.getColaboraciones();
            }

            List<DtColaboracion> colaboracionesConPago = new ArrayList<>();
            for (DtColaboracion colab : todasLasColaboraciones) {
                if (colab.getMonto() != null && colab.getMonto() > 0) {
                    colaboracionesConPago.add(colab);
                }
            }

            request.setAttribute("colaboraciones", colaboracionesConPago);
            request.setAttribute("colaborador", colaborador);

            boolean esColaboradorActual = true;
            boolean esProponenteActual = false;
            try {
                ICU.devolverProponentePorNickname(usuarioActual.getNickname());
                esProponenteActual = true;
            } catch (Exception e) {
                esProponenteActual = false;
            }
            request.setAttribute("esProponente", esProponenteActual);
            request.setAttribute("esColaborador", esColaboradorActual);

            request.getRequestDispatcher("/listarColaboracionesConstancia.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar colaboraciones: " + e.getMessage());
            request.getRequestDispatcher("/listarColaboracionesConstancia.jsp").forward(request, response);
        }
    }
}

