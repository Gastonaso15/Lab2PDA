package com.culturarteWeb.servlets;

import culturarte.logica.DTs.*;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.IUsuarioController;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/registrarColaboracionAPropuesta")
public class RegistrarColaboracionAPropuestaServlet extends HttpServlet {

    private IPropuestaController IPC;
    private IUsuarioController IUC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
        IUC = fabrica.getIUsuarioController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        DTUsuario usuarioLogueado = (DTUsuario) session.getAttribute("usuarioLogueado");
        if (!(usuarioLogueado instanceof DTColaborador)) {
            request.setAttribute("error", "Solo los colaboradores pueden registrar colaboraciones.");
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
            return;
        }

        String tituloPropuesta = request.getParameter("titulo");
        String modo = request.getParameter("modo");

        if ("detalle".equalsIgnoreCase(modo) && tituloPropuesta != null) {

            DTPropuesta propuesta = IPC.getDTPropuesta(tituloPropuesta);
            if (propuesta == null) {
                request.setAttribute("error", "Propuesta no encontrada.");
                doListarPropuestas(request, response);
                return;
            }

            // Solo se puede colaborar si está ACTIVA, INGRESADA o EN_FINANCIACION
            if (propuesta.getEstadoActual() == DTEstadoPropuesta.CANCELADA ||
                    propuesta.getEstadoActual() == DTEstadoPropuesta.FINANCIADA) {

                request.setAttribute("error", "No se puede colaborar con una propuesta en estado " + propuesta.getEstadoActual());
                doListarPropuestas(request, response);
                return;
            }

            List<DTTipoRetorno> tiposRetorno = IPC.listarTiposRetorno(tituloPropuesta);

            request.setAttribute("propuesta", propuesta);
            request.setAttribute("tiposRetorno", tiposRetorno);
            request.getRequestDispatcher("/WEB-INF/registrarColaboracionAPropuesta.jsp").forward(request, response);

        } else {
            doListarPropuestas(request, response);
        }
    }

    private void doListarPropuestas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<DTPropuesta> propuestas = IPC.listarPropuestas().stream()
                .filter(p.getEstado() == DTEstadoPropuesta.INGRESADA ||
                        p.getEstado() == DTEstadoPropuesta.EN_FINANCIACION)
                .collect(Collectors.toList());

        request.setAttribute("propuestas", propuestas);
        request.getRequestDispatcher("/WEB-INF/registrarColaboracionAPropuesta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        DTColaborador colaborador = (DTColaborador) session.getAttribute("usuarioLogueado");

        String tituloPropuesta = request.getParameter("titulo");
        String tipoRetornoNombre = request.getParameter("tipoRetorno");
        String montoStr = request.getParameter("monto");

        String mensaje = null;
        String error = null;

        try {
            if (tituloPropuesta == null || tipoRetornoNombre == null || montoStr == null || montoStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Faltan campos obligatorios para la colaboración.");
            }

            double monto = Double.parseDouble(montoStr);
            if (monto <= 0) throw new IllegalArgumentException("El monto debe ser mayor a cero.");

            DTPropuesta propuesta = IPC.getDTPropuesta(tituloPropuesta);
            if (propuesta == null)
                throw new IllegalArgumentException("Propuesta no encontrada.");

            List<DTTipoRetorno> tiposRetorno = IPC.listarTiposRetorno(tituloPropuesta);
            DTTipoRetorno tipoSeleccionado = tiposRetorno.stream()
                    .filter(tr -> tr.getNombre().equals(tipoRetornoNombre))
                    .findFirst()
                    .orElseThrow(() -> new IllegalArgumentException("Tipo de retorno no válido."));

            if (monto < tipoSeleccionado.getMontoMinimo()) {
                throw new IllegalArgumentException("El monto $" + monto + " es menor al mínimo de $" +
                        tipoSeleccionado.getMontoMinimo() + " para el tipo de retorno " + tipoRetornoNombre);
            }

            DTColaboracion colaboracion = new DTColaboracion(
                    propuesta,
                    colaborador,
                    monto,
                    tipoSeleccionado,
                    LocalDateTime.now()
            );

            IPC.registrarColaboracion(tituloPropuesta, colaboracion);
            mensaje = "Colaboración registrada exitosamente en la propuesta '" + tituloPropuesta + "'.";

        } catch (NumberFormatException e) {
            error = "El monto debe ser un número válido.";
        } catch (Exception e) {
            error = e.getMessage();
            e.printStackTrace();
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("titulo", tituloPropuesta);
            request.setAttribute("modo", "detalle");
            doGet(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/consultaPropuesta?mensaje=" + java.net.URLEncoder.encode(mensaje, "UTF-8"));
        }
    }
}
