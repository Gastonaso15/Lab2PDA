package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaUsuario;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
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
import java.time.format.DateTimeFormatter;

@WebServlet("/generarPDFConstancia")
public class GenerarPDFConstanciaServlet extends HttpServlet {

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

        String tituloPropuesta = request.getParameter("tituloPropuesta");
        
        if (tituloPropuesta == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Debe especificar una colaboración.");
            return;
        }

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");
        
        try {
            DtColaborador colaborador = ICU.devolverColaboradorPorNickname(usuarioActual.getNickname());

            DtColaboracion colaboracionSeleccionada = null;
            if (colaborador != null && colaborador.getColaboraciones() != null) {
                for (DtColaboracion colab : colaborador.getColaboraciones()) {
                    if (colab.getPropuesta() != null && 
                        colab.getPropuesta().getTitulo().equals(tituloPropuesta)) {
                        colaboracionSeleccionada = colab;
                        break;
                    }
                }
            }

            if (colaboracionSeleccionada == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "No se encontró la colaboración especificada.");
                return;
            }

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"constancia_pago_" + 
                colaborador.getNickname() + "_" + 
                tituloPropuesta.replaceAll("[^a-zA-Z0-9]", "_") + ".pdf\"");

            PdfWriter writer = new PdfWriter(response.getOutputStream());
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            Paragraph titulo = new Paragraph("CONSTANCIA DE PAGO DE COLABORACIÓN")
                .setFontSize(18)
                .setBold()
                .setTextAlignment(TextAlignment.CENTER)
                .setMarginBottom(20);
            document.add(titulo);

            Paragraph plataforma = new Paragraph("Plataforma Culturarte")
                .setFontSize(14)
                .setTextAlignment(TextAlignment.CENTER)
                .setMarginBottom(30);
            document.add(plataforma);

            LocalDate fechaEmision = LocalDate.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            Paragraph fechaEmisionPar = new Paragraph("Fecha de emisión: " + fechaEmision.format(formatter))
                .setFontSize(12)
                .setMarginBottom(20);
            document.add(fechaEmisionPar);

            Paragraph datosColaboradorTitulo = new Paragraph("Datos del Colaborador")
                .setFontSize(14)
                .setBold()
                .setMarginBottom(10);
            document.add(datosColaboradorTitulo);

            Table tablaColaborador = new Table(UnitValue.createPercentArray(new float[]{1, 2}));
            tablaColaborador.setWidth(UnitValue.createPercentValue(100));
            
            agregarFilaTabla(tablaColaborador, "Nickname:", colaborador.getNickname());
            agregarFilaTabla(tablaColaborador, "Nombre:", colaborador.getNombre() + " " + colaborador.getApellido());
            agregarFilaTabla(tablaColaborador, "Correo:", colaborador.getCorreo() != null ? colaborador.getCorreo() : "N/A");
            if (colaborador.getFechaNacimiento() != null) {
                LocalDate fechaNac = WSFechaUsuario.toJavaLocalDate(colaborador.getFechaNacimiento());
                if (fechaNac != null) {
                    agregarFilaTabla(tablaColaborador, "Fecha de Nacimiento:", fechaNac.format(formatter));
                }
            }
            
            document.add(tablaColaborador);
            document.add(new Paragraph().setMarginBottom(20));

            Paragraph datosColaboracionTitulo = new Paragraph("Datos de la Colaboración")
                .setFontSize(14)
                .setBold()
                .setMarginBottom(10);
            document.add(datosColaboracionTitulo);

            Table tablaColaboracion = new Table(UnitValue.createPercentArray(new float[]{1, 2}));
            tablaColaboracion.setWidth(UnitValue.createPercentValue(100));
            
            agregarFilaTabla(tablaColaboracion, "Propuesta:", colaboracionSeleccionada.getPropuesta().getTitulo());
            agregarFilaTabla(tablaColaboracion, "Monto:", "$" + String.format("%.2f", colaboracionSeleccionada.getMonto()));
            
            if (colaboracionSeleccionada.getFechaHora() != null) {
                LocalDateTime fechaHora = WSFechaUsuario.toJavaLocalDateTime(colaboracionSeleccionada.getFechaHora());
                if (fechaHora != null) {
                    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                    agregarFilaTabla(tablaColaboracion, "Fecha y Hora:", fechaHora.format(dateTimeFormatter));
                }
            }
            
            if (colaboracionSeleccionada.getTipoRetorno() != null) {
                agregarFilaTabla(tablaColaboracion, "Tipo de Retorno:", colaboracionSeleccionada.getTipoRetorno().toString());
            }
            
            document.add(tablaColaboracion);
            document.add(new Paragraph().setMarginBottom(20));

            Paragraph datosPagoTitulo = new Paragraph("Datos del Pago")
                .setFontSize(14)
                .setBold()
                .setMarginBottom(10);
            document.add(datosPagoTitulo);

            Table tablaPago = new Table(UnitValue.createPercentArray(new float[]{1, 2}));
            tablaPago.setWidth(UnitValue.createPercentValue(100));
            
            agregarFilaTabla(tablaPago, "Monto Pagado:", "$" + String.format("%.2f", colaboracionSeleccionada.getMonto()));
            agregarFilaTabla(tablaPago, "Estado:", "Pagado");
            
            if (colaboracionSeleccionada.getFechaHora() != null) {
                LocalDateTime fechaHora = WSFechaUsuario.toJavaLocalDateTime(colaboracionSeleccionada.getFechaHora());
                if (fechaHora != null) {
                    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                    agregarFilaTabla(tablaPago, "Fecha de Pago:", fechaHora.format(dateTimeFormatter));
                }
            }
            
            document.add(tablaPago);

            document.add(new Paragraph().setMarginBottom(30));
            Paragraph pie = new Paragraph("Este documento es una constancia oficial emitida por la plataforma Culturarte.")
                .setFontSize(10)
                .setTextAlignment(TextAlignment.CENTER)
                .setItalic();
            document.add(pie);

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error al generar PDF: " + e.getMessage());
        }
    }

    private void agregarFilaTabla(Table tabla, String etiqueta, String valor) {
        Paragraph etiquetaPar = new Paragraph(etiqueta).setBold();
        Paragraph valorPar = new Paragraph(valor != null ? valor : "N/A");
        tabla.addCell(etiquetaPar);
        tabla.addCell(valorPar);
    }
}

