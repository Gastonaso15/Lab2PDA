package com.culturarteWeb.servlets;

import culturarte.logica.manejadores.PropuestaManejador;
import culturarte.logica.modelos.Propuesta;
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

        PropuestaManejador pm = PropuestaManejador.getInstance();

        // Obtener todas las propuestas
        List<DTPropuesta> propuestas = pm.obtenerTodasLasPropuestas();
        request.setAttribute("propuestas", propuestas);

        // Si viene con un título seleccionado, mostrar también los detalles
        String tituloSeleccionado = request.getParameter("titulo");
        if (tituloSeleccionado != null && !tituloSeleccionado.isEmpty()) {
            Propuesta propuesta = pm.obtenerPropuestaPorTitulo(tituloSeleccionado);
            if (propuesta != null) {
                request.setAttribute("propuestaSeleccionada", propuesta.getDataType());
            } else {
                request.setAttribute("error", "La propuesta seleccionada no existe.");
            }
        }

        request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PropuestaManejador pm = PropuestaManejador.getInstance();
        String accion = request.getParameter("accion");

        // Si cancela
        if ("cancelar".equals(accion)) {
            response.sendRedirect("principal.jsp");
            return;
        }

        // Si selecciona una propuesta para ver detalles
        if ("seleccionar".equals(accion)) {
            String titulo = request.getParameter("titulo");
            response.sendRedirect("registrarColaboracion?titulo=" + titulo);
            return;
        }

        // Si confirma colaboración
        if ("confirmar".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String montoStr = request.getParameter("monto");
            String tipoRetorno = request.getParameter("tipoRetorno");

            try {
                double monto = Double.parseDouble(montoStr);

                // En una versión real se llamaría al controlador lógico para registrar la colaboración
                // Ejemplo:
                // colaboracionController.registrarColaboracion(usuarioActual, titulo, monto, tipoRetorno);

                request.setAttribute("mensaje", "Colaboración registrada correctamente en la propuesta '" + titulo + "'. Monto: $" + monto);
            } catch (NumberFormatException e) {
                request.setAttribute("error", "El monto ingresado no es válido.");
            }

            List<DTPropuesta> propuestas = pm.obtenerTodasLasPropuestas();
            request.setAttribute("propuestas", propuestas);
            request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
        }
    }
}
