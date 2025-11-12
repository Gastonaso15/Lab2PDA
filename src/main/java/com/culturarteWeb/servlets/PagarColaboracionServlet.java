package com.culturarteWeb.servlets;

import com.culturarteWeb.util.EmailService;
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

import com.culturarteWeb.util.WSFechaPropuesta;
import java.io.IOException;
import java.lang.Exception;
import java.util.List;
import java.time.LocalDateTime;

@WebServlet("/pagarColaboracion")
public class PagarColaboracionServlet extends HttpServlet {

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
            request.setAttribute("error", "Debes iniciar sesión para realizar un pago.");
            request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
            return;
        }

        String idColaboracionStr = request.getParameter("idColaboracion");
        if (idColaboracionStr == null || idColaboracionStr.isEmpty()) {
            request.setAttribute("error", "Debe especificar una colaboración.");
            request.getRequestDispatcher("/listarColaboracionesParaPagar").forward(request, response);
            return;
        }

        try {
            Long idColaboracion = Long.parseLong(idColaboracionStr);

            ListaDTColaboracion listaColaboracionesWS = IPC.devolverColaboracionesSinPago(usuarioActual.getNickname());
            List<DtColaboracion> colaboraciones = listaColaboracionesWS.getColaboracion();
            
            DtColaboracion colaboracionSeleccionada = null;
            if (colaboraciones != null) {
                for (DtColaboracion colab : colaboraciones) {
                    if (colab.getId() != null && colab.getId().equals(idColaboracion)) {
                        colaboracionSeleccionada = colab;
                        break;
                    }
                }
            }

            if (colaboracionSeleccionada == null) {
                request.setAttribute("error", "La colaboración especificada no existe o ya tiene un pago asociado.");
                request.getRequestDispatcher("/listarColaboracionesParaPagar").forward(request, response);
                return;
            }

            request.setAttribute("colaboracion", colaboracionSeleccionada);
            request.getRequestDispatcher("/pagarColaboracion.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la colaboración: " + e.getMessage());
            request.getRequestDispatcher("/listarColaboracionesParaPagar").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");

        if (usuarioActual == null) {
            request.setAttribute("error", "Debes iniciar sesión para realizar un pago.");
            request.getRequestDispatcher("/inicioDeSesion.jsp").forward(request, response);
            return;
        }

        try {
            Long idColaboracion = Long.parseLong(request.getParameter("idColaboracion"));
            Double monto = Double.parseDouble(request.getParameter("monto"));
            String formaPagoStr = request.getParameter("formaPago");

            DtColaboracion colaboracion = null;
            ListaDTColaboracion listaColaboracionesWS = IPC.devolverColaboracionesSinPago(usuarioActual.getNickname());
            List<DtColaboracion> colaboraciones = listaColaboracionesWS.getColaboracion();
            
            if (colaboraciones != null) {
                for (DtColaboracion colab : colaboraciones) {
                    if (colab.getId() != null && colab.getId().equals(idColaboracion)) {
                        colaboracion = colab;
                        break;
                    }
                }
            }
            
            if (colaboracion == null) {
                request.setAttribute("error", "La colaboración especificada no existe o ya tiene un pago asociado.");
                response.sendRedirect("listarColaboracionesParaPagar");
                return;
            }
            
            DtPago dtPago = new DtPago();
            dtPago.setMonto(monto);
            dtPago.setFechaPago(WSFechaPropuesta.toWSLocalDateTimeWS(LocalDateTime.now()));

            DtTipoFormaPago formaPago;
            try {
                formaPago = DtTipoFormaPago.valueOf(formaPagoStr);
            } catch (Exception e) {
                request.setAttribute("error", "Forma de pago inválida.");
                response.sendRedirect("pagarColaboracion?idColaboracion=" + idColaboracion);
                return;
            }
            dtPago.setFormaPago(formaPago);

            if (formaPago == DtTipoFormaPago.TARJETA) {
                DtTipoTarjeta tipoTarjeta;
                try {
                    tipoTarjeta = DtTipoTarjeta.valueOf(request.getParameter("tipoTarjeta"));
                } catch (Exception e) {
                    request.setAttribute("error", "Tipo de tarjeta inválido.");
                    response.sendRedirect("pagarColaboracion?idColaboracion=" + idColaboracion);
                    return;
                }
                dtPago.setTipoTarjeta(tipoTarjeta);
                dtPago.setNumeroTarjeta(request.getParameter("numeroTarjeta"));
                dtPago.setFechaVencimiento(request.getParameter("fechaVencimiento"));
                dtPago.setCvc(request.getParameter("cvc"));
                dtPago.setNombreTitularTarjeta(request.getParameter("nombreTitularTarjeta"));
            } else if (formaPago == DtTipoFormaPago.TRANSFERENCIA_BANCARIA) {
                dtPago.setNombreBanco(request.getParameter("nombreBanco"));
                dtPago.setNumeroCuenta(request.getParameter("numeroCuenta"));
                dtPago.setNombreTitularTransferencia(request.getParameter("nombreTitularTransferencia"));
            } else if (formaPago == DtTipoFormaPago.PAYPAL) {
                dtPago.setNumeroCuentaPayPal(request.getParameter("numeroCuentaPayPal"));
                dtPago.setNombreTitularPayPal(request.getParameter("nombreTitularPayPal"));
            }

            IPC.registrarPago(idColaboracion, dtPago);

            if (colaboracion != null && colaboracion.getPropuesta() != null) {
                try {
                    String emailColaborador = usuarioActual.getCorreo();
                    String emailProponente = ICU.getDTUsuario(colaboracion.getPropuesta().getDTProponente().getNickname())
                            .getCorreo();

                    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" +
                            request.getServerPort() + request.getContextPath();

                    EmailService emailService = new EmailService();
                    if (emailColaborador != null) {
                        emailService.enviarNotificacionPagoColaborador(emailColaborador, usuarioActual.getNickname(),
                            colaboracion, dtPago, baseUrl);
                    }
                    if (emailProponente != null) {
                        emailService.enviarNotificacionPagoProponente(emailProponente,
                                colaboracion.getPropuesta().getDTProponente().getNickname(), colaboracion, dtPago);
                    }
                } catch (Exception e) {
                    System.err.println("Error al enviar emails de notificación: " + e.getMessage());
                }
            }

            session.setAttribute("mensajeGlobal", "¡El pago ha sido registrado con éxito!");
            response.sendRedirect(request.getContextPath() + "/listarColaboracionesParaPagar");
        } catch (Exception e) {
            request.setAttribute("error", "Error al registrar el pago: " + e.getMessage());
            String idColaboracionStr = request.getParameter("idColaboracion");
            response.sendRedirect("pagarColaboracion?idColaboracion=" + idColaboracionStr);
        }
    }
}

