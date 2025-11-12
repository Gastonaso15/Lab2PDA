package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.*;
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
import java.lang.Exception;
import java.util.List;

@WebServlet("/listarColaboracionesParaPagar")
public class ListarColaboracionesParaPagarServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();
        } catch (java.lang.Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            request.setAttribute("error", "Debes iniciar sesión para ver tus colaboraciones.");
            request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
            return;
        }

        String tipo;
        try {
            ICU.devolverColaboradorPorNickname(usuarioActual.getNickname());
            tipo = "Colaborador";
        } catch (Exception ex) {
            tipo = "Proponente";
        }

        if (tipo.equals("Proponente")) {
            request.setAttribute("error", "Solo los colaboradores pueden pagar colaboraciones.");
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
            return;
        }

        try {
            ListaDTColaboracion listaColaboracionesWS = IPC.devolverColaboracionesSinPago(usuarioActual.getNickname());
            List<DtColaboracion> colaboraciones = listaColaboracionesWS.getColaboracion();

            request.setAttribute("colaboraciones", colaboraciones);
            request.getRequestDispatcher("/listarColaboracionesParaPagar.jsp").forward(request, response);

        } catch (java.lang.Exception e) {
            request.setAttribute("error", "Error al obtener colaboraciones: " + e.getMessage());
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }
    }
}

