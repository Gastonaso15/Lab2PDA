package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaUsuario;
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
import java.time.LocalDate;
import java.time.LocalDateTime;

@WebServlet("/emitirConstanciaPago")
public class EmitirConstanciaPagoServlet extends HttpServlet {

    private IUsuarioControllerWS ICU;
    private IPropuestaControllerWS IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();
            
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

        String colaboracionId = request.getParameter("colaboracionId");
        String tituloPropuesta = request.getParameter("tituloPropuesta");
        
        if (colaboracionId == null && tituloPropuesta == null) {
            request.setAttribute("error", "Debe especificar una colaboración.");
            request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
            return;
        }

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");
        
        try {
            DtColaborador colaborador = ICU.devolverColaboradorPorNickname(usuarioActual.getNickname());
            
            DtColaboracion colaboracionSeleccionada = null;
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                for (DtColaboracion colab : colaborador.getColaboraciones()) {
                    if (tituloPropuesta != null && colab.getPropuesta() != null && 
                        colab.getPropuesta().getTitulo().equals(tituloPropuesta)) {
                        colaboracionSeleccionada = colab;
                        break;
                    }
                }
            }

            if (colaboracionSeleccionada == null) {
                request.setAttribute("error", "No se encontró la colaboración especificada.");
                request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
                return;
            }

            if (colaboracionSeleccionada.getMonto() == null || colaboracionSeleccionada.getMonto() <= 0) {
                request.setAttribute("error", "Esta colaboración no tiene un pago asociado.");
                request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
                return;
            }

            // Verificar que la constancia no esté ya emitida
            if (colaboracionSeleccionada.isConstanciaEmitida() != null && colaboracionSeleccionada.isConstanciaEmitida()) {
                request.setAttribute("error", "Esta constancia ya ha sido emitida anteriormente y no puede volver a emitirse.");
                request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
                return;
            }

            // Verificar que tenga un ID válido
            if (colaboracionSeleccionada.getId() == null) {
                request.setAttribute("error", "La colaboración no tiene un ID válido.");
                request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
                return;
            }

            // Marcar la constancia como emitida al mostrar la vista previa
            try {
                IPC.marcarConstanciaEmitida(colaboracionSeleccionada.getId());
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Error al marcar la constancia como emitida: " + e.getMessage());
                request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
                return;
            }

            LocalDate fechaEmision = LocalDate.now();
            LocalDateTime fechaHoraColaboracion = null;
            if (colaboracionSeleccionada.getFechaHora() != null) {
                fechaHoraColaboracion = WSFechaUsuario.toJavaLocalDateTime(colaboracionSeleccionada.getFechaHora());
            }

            request.setAttribute("colaboracion", colaboracionSeleccionada);
            request.setAttribute("colaborador", colaborador);
            request.setAttribute("fechaEmision", fechaEmision);
            request.setAttribute("fechaHoraColaboracion", fechaHoraColaboracion);
            
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

            request.getRequestDispatcher("/emitirConstanciaPago.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al generar constancia: " + e.getMessage());
            request.getRequestDispatcher("/listarColaboracionesConstancia").forward(request, response);
        }
    }
}

