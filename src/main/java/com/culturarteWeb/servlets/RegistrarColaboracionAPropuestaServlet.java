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
                    propEstado.setEstado(DtEstadoPropuesta.EN_FINANCIACION);
                    propEstado.setFechaCambio(WSFechaPropuesta.toWSLocalDateWS(java.time.LocalDate.now()));

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
            // Obtener la propuesta de la lista de todas las propuestas
            // (igual que en el servidor central que usa devolverTodasLasPropuestas)
            DtPropuesta propuesta = null;
            
            // Buscar la propuesta en la lista de todas las propuestas (viene de la base de datos)
            for (DtPropuesta p : propuestas) {
                if (p.getTitulo() != null && p.getTitulo().equals(tituloSeleccionado)) {
                    propuesta = p;
                    break;
                }
            }
            
            // Si no se encontró en la lista, intentar con getDTPropuesta
            if (propuesta == null) {
                propuesta = IPC.getDTPropuesta(tituloSeleccionado);
            }

            if (propuesta != null) {
                request.setAttribute("propuestaSeleccionada", propuesta);
                
                // Obtener los tipos de retorno directamente de la propuesta (vienen de la base de datos)
                // Igual que en el servidor central: propuesta.getTiposRetorno()
                List<DtTipoRetorno> tiposRetorno = propuesta.getTiposRetorno();
                
                // El método getTiposRetorno() inicializa lista vacía si es null, pero verificamos por si acaso
                if (tiposRetorno == null) {
                    tiposRetorno = new java.util.ArrayList<DtTipoRetorno>();
                }
                
                // Filtrar valores nulos y crear lista válida
                List<DtTipoRetorno> tiposRetornoValidos = new java.util.ArrayList<DtTipoRetorno>();
                for (DtTipoRetorno tipo : tiposRetorno) {
                    if (tipo != null) {
                        tiposRetornoValidos.add(tipo);
                    }
                }
                
                // SIEMPRE establecer tiposRetorno en el request para que el JSP pueda mostrarlos
                request.setAttribute("tiposRetorno", tiposRetornoValidos);
                
                // Debug para verificar qué viene de la base de datos
                System.out.println("=== Tipos de Retorno desde BD para '" + propuesta.getTitulo() + "' ===");
                System.out.println("Total en lista: " + tiposRetorno.size());
                System.out.println("Total válidos: " + tiposRetornoValidos.size());
                if (tiposRetornoValidos.isEmpty()) {
                    System.err.println("⚠ ADVERTENCIA: La propuesta no tiene tipos de retorno en la lista");
                } else {
                    for (DtTipoRetorno tr : tiposRetornoValidos) {
                        System.out.println("  ✓ " + tr.toString());
                    }
                }
                System.out.println("=========================================");
            } else {
                // Si no se encontró la propuesta, establecer lista vacía
                request.setAttribute("tiposRetorno", new java.util.ArrayList<DtTipoRetorno>());
            }
        } else {
            // Si no hay propuesta seleccionada, establecer lista vacía
            request.setAttribute("tiposRetorno", new java.util.ArrayList<DtTipoRetorno>());
        }
    }
}
