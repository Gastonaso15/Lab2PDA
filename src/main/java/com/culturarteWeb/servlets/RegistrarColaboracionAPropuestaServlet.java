/*
package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.lang.Exception;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static java.net.URLEncoder.encode;

@WebServlet("/registrarColaboracion")
public class RegistrarColaboracionAPropuestaServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;

    @Override
    public void init() throws ServletException {
        super.init();
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
        cargarDatosParaLaVista(request, request.getParameter("titulo"));
        request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        HttpSession session = request.getSession();

        if ("cancelar".equals(accion)) {
            response.sendRedirect("principal");
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

            DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                request.setAttribute("error", "Debes iniciar sesión para poder colaborar.");
                request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
                return;
            }

            try {
                double monto = Double.parseDouble(montoStr);

                DtPropuesta propuesta = IPC.getDTPropuesta(titulo);
                
                boolean esPrimeraColaboracion = false;
                if (propuesta != null && propuesta.getColaboraciones() != null && propuesta.getColaboraciones().isEmpty()) {
                    esPrimeraColaboracion = true;
                }

                IPC.registrarColaboracion(titulo,usuarioActual.getNickname(), monto, tipoRetorno);

                if (esPrimeraColaboracion && propuesta != null && 
                    propuesta.getEstadoActual().toString().equals("PUBLICADA")) {
                    
                    propuesta.setEstadoActual(DtEstadoPropuesta.EN_FINANCIACION);

                    DtPropuestaEstado propEstado = new DtPropuestaEstado();
                    propEstado.setPropuesta(propuesta);
                    propEstado.setEstado(DtEstadoPropuesta.EN_FINANCIACION);
                    propEstado.setFechaCambio(WSFechaPropuesta.toWSLocalDate(java.time.LocalDate.now()));

                    propuesta.getHistorial().add(propEstado);

                    IPC.modificarHistorialYEstadoPropuesta(propuesta);
                }
                
                session.setAttribute("mensajeGlobal", "¡Tu colaboración ha sido registrada con éxito!");
                response.sendRedirect(request.getContextPath() + "/consultaPropuesta?accion=detalle&titulo=" + encode(titulo, "UTF-8"));

            } catch (NumberFormatException e) {
                request.setAttribute("error", "El monto ingresado no es válido.");
                cargarDatosParaLaVista(request, titulo);
                request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);

            } catch (Exception e) {
                request.setAttribute("error", "Error al registrar la colaboración: " + e.getMessage());
                cargarDatosParaLaVista(request, titulo);
                request.getRequestDispatcher("/registrarColaboracionAPropuesta.jsp").forward(request, response);
            }
        }
    }

    private void cargarDatosParaLaVista(HttpServletRequest request, String tituloSeleccionado) {

        ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
        List<DtPropuesta> propuestas = propuestasWS.getPropuesta();

        request.setAttribute("propuestas", propuestas);

        if (tituloSeleccionado != null && !tituloSeleccionado.isEmpty()) {
            DtPropuesta propuesta = IPC.getDTPropuesta(tituloSeleccionado);

            if (propuesta != null) {
                request.setAttribute("propuestaSeleccionada", propuesta);
            }
        }
    }
}
*/