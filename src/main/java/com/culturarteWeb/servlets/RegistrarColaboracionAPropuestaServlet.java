package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.manejadores.PropuestaManejador;
import culturarte.logica.modelos.Propuesta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static java.net.URLEncoder.encode;

@WebServlet("/registrarColaboracion")
public class RegistrarColaboracionAPropuestaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // La lógica para mostrar la página es correcta, no necesita cambios.
        cargarDatosParaLaVista(request, request.getParameter("titulo"));
        request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        HttpSession session = request.getSession();

        if ("cancelar".equals(accion)) {
            response.sendRedirect("principal"); // Redirige al servlet principal
            return;
        }

        if ("seleccionar".equals(accion)) {
            String titulo = request.getParameter("titulo");
            response.sendRedirect("registrarColaboracion?titulo=" + URLEncoder.encode(titulo, StandardCharsets.UTF_8));
            return;
        }

        if ("confirmar".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String montoStr = request.getParameter("monto");
            String tipoRetorno = request.getParameter("tipoRetorno");

            // 1. Obtener el usuario actual de la sesión
            DTUsuario usuarioActual = (DTUsuario) session.getAttribute("usuarioLogueado");

            // 2. Verificación de seguridad: si no hay usuario, no se puede colaborar
            if (usuarioActual == null) {
                request.setAttribute("error", "Debes iniciar sesión para poder colaborar.");
                request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
                return;
            }

            try {
                double monto = Double.parseDouble(montoStr);

                // --- LÓGICA REAL PARA REGISTRAR LA COLABORACIÓN ---
                // 3. Obtener el controlador de Propuestas desde la Fábrica
                IPropuestaController pc = Fabrica.getInstance().getIPropuestaController();

                // 4. Llamar al método del caso de uso para guardar en la BD
                pc.registrarColaboracion(titulo,usuarioActual.getNickname(), monto, tipoRetorno);

                // --- ÉXITO: REDIRIGIR A LA PÁGINA DE DETALLES ---
                // 5. Guardar un mensaje de éxito en la sesión (flash message)
                session.setAttribute("mensajeGlobal", "¡Tu colaboración ha sido registrada con éxito!");

                // 6. Redirigir al servlet de detallePropuesta, pasando el título
                response.sendRedirect(request.getContextPath() + "/consultaPropuesta?accion=detalle&titulo=" + encode(titulo, "UTF-8"));

            } catch (NumberFormatException e) {
                // Error si el monto no es un número válido
                request.setAttribute("error", "El monto ingresado no es válido.");
                cargarDatosParaLaVista(request, titulo);
                request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
            } catch (Exception e) {
                // Captura cualquier otro error que venga de la capa lógica (ej: propuesta no existe)
                request.setAttribute("error", "Error al registrar la colaboración: " + e.getMessage());
                cargarDatosParaLaVista(request, titulo);
                request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
            }
        }
    }

    /**
     * Método de ayuda para cargar los datos necesarios para renderizar el JSP,
     * tanto en el GET inicial como al recargar la página por un error en el POST.
     * @param request La solicitud HTTP.
     * @param tituloSeleccionado El título de la propuesta que debe aparecer seleccionada.
     */
    private void cargarDatosParaLaVista(HttpServletRequest request, String tituloSeleccionado) {
        PropuestaManejador pm = PropuestaManejador.getInstance();
        List<DTPropuesta> propuestas = pm.obtenerTodasLasPropuestas();
        request.setAttribute("propuestas", propuestas);

        if (tituloSeleccionado != null && !tituloSeleccionado.isEmpty()) {
            Propuesta propuesta = pm.obtenerPropuestaPorTitulo(tituloSeleccionado);
            if (propuesta != null) {
                request.setAttribute("propuestaSeleccionada", propuesta.getDataType());
            }
        }
    }
}
