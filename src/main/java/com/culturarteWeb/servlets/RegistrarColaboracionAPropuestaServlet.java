package com.culturarteWeb.servlets;

import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.ISesionController;
import culturarte.logica.DTs.DTPropuesta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/registrarColaboracion")
public class RegistrarColaboracionAPropuestaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Fabrica fabrica = Fabrica.getInstance();
        IPropuestaController iProp = fabrica.getIPropuestaController();

        // Mostrar todas las propuestas para seleccionar
        List<DTPropuesta> propuestas = iProp.devolverTodasLasPropuestas();
        request.setAttribute("propuestas", propuestas);
        request.getRequestDispatcher("/WEB-INF/registrarColaboracion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Fabrica fabrica = Fabrica.getInstance();
        IPropuestaController iProp = fabrica.getIPropuestaController();
        ISesionController iSes = fabrica.getISesionController();

        String accion = request.getParameter("accion");

        try {
            if ("seleccionar".equals(accion)) {
                // El usuario selecciona una propuesta
                String titulo = request.getParameter("titulo");
                DTPropuesta propuesta = iProp.getDTPropuesta(titulo);

                request.setAttribute("propuesta", propuesta);
                request.setAttribute("tiposRetorno", propuesta.getTiposRetorno());
                request.getRequestDispatcher("/WEB-INF/confirmarColaboracion.jsp").forward(request, response);
                return;

            } else if ("confirmar".equals(accion)) {
                String titulo = request.getParameter("titulo");
                String tipoRetorno = request.getParameter("tipoRetorno");
                Double monto = Double.parseDouble(request.getParameter("monto"));
                String nicknameColaborador = iSes.getUsuarioActual().getNickname();

                iProp.registrarColaboracion(titulo, nicknameColaborador, monto, tipoRetorno);

                request.setAttribute("mensaje", "Colaboración registrada correctamente.");
                request.getRequestDispatcher("/WEB-INF/exito.jsp").forward(request, response);
                return;

            } else if ("cancelar".equals(accion)) {
                response.sendRedirect("home.jsp");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al registrar la colaboración: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/error.jsp").forward(request, response);
        }
    }
}