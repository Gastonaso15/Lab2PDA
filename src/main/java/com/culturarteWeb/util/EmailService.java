package com.culturarteWeb.util;

import culturarte.servicios.cliente.propuestas.DtColaboracion;
import culturarte.servicios.cliente.propuestas.DtPago;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Properties;

public class EmailService {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;
    private static final String FROM_EMAIL = "culturarteUTEC@gmail.com";
    private static final String FROM_NAME = "Culturarte";
    private static final String USERNAME = "culturarteUTEC@gmail.com";
    private static final String PASSWORD = "dgii esvb wsrh utjv";

    private final Session session;

    public EmailService() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(SMTP_PORT));
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        this.session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });
    }

    public void enviarNotificacionPagoColaborador(String emailDestinatario, String nombreColaborador, DtColaboracion
            colaboracion, DtPago pago, String baseUrl) throws MessagingException {

        LocalDateTime fechaPago = WSFechaPropuesta.toJavaLocalDateTime(pago.getFechaPago());
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");
        String fechaPagoStr = fechaPago.format(formatter);

        String tituloPropuesta = colaboracion.getPropuesta().getTitulo();
        String nombreProponente = colaboracion.getPropuesta().getDTProponente().getNickname();
        String nombreColab = colaboracion.getColaborador().getNickname();
        Double monto = colaboracion.getMonto();

        String asunto = "[Culturarte] [" + fechaPagoStr + "] Pago de colaboración registrado";

        String cuerpo = generarCuerpoEmailColaborador(nombreColaborador, tituloPropuesta, nombreProponente,
                nombreColab, monto, fechaPagoStr, baseUrl);

        enviarEmail(emailDestinatario, asunto, cuerpo);
    }

    public void enviarNotificacionPagoProponente(String emailDestinatario, String nombreProponente, DtColaboracion
            colaboracion, DtPago pago) throws MessagingException {

        LocalDateTime fechaPago = WSFechaPropuesta.toJavaLocalDateTime(pago.getFechaPago());
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");
        String fechaPagoStr = fechaPago.format(formatter);

        String tituloPropuesta = colaboracion.getPropuesta().getTitulo();
        String nombreColab = colaboracion.getColaborador().getNickname();
        Double monto = colaboracion.getMonto();

        String asunto = "[Culturarte] [" + fechaPagoStr + "] Pago de colaboración registrado";

        String cuerpo = generarCuerpoEmailProponente(nombreProponente, tituloPropuesta, nombreColab, monto, fechaPagoStr);

        enviarEmail(emailDestinatario, asunto, cuerpo);
    }

    private String generarCuerpoEmailColaborador( String nombreColaborador, String tituloPropuesta, String
            nombreProponente, String nombreColab, Double monto, String fechaPagoStr, String baseUrl) {

        String tituloParam = tituloPropuesta.replace(" ", "+");
        String urlConstancia = baseUrl + "/emitirConstanciaPago?tituloPropuesta=" + tituloParam;

        return "<!DOCTYPE html>" +
                "<html><head><meta charset='UTF-8'>" +
                "<style>" +
                "body{font-family:Arial,sans-serif;line-height:1.6;color:#333;}" +
                ".container{max-width:600px;margin:0 auto;padding:20px;}" +
                ".header{background-color:#4CAF50;color:white;padding:20px;text-align:center;}" +
                ".content{padding:20px;background-color:#f9f9f9;}" +
                ".details{background-color:white;padding:15px;margin:15px 0;border-left:4px solid #4CAF50;}" +
                ".footer{text-align:center;margin-top:20px;padding:20px;color:#666;}" +
                "a.button{background-color:#4CAF50;color:white;padding:10px 15px;text-decoration:none;border-radius:5px;}" +
                "</style></head>" +
                "<body><div class='container'><div class='header'><h1>Culturarte</h1></div>" +
                "<div class='content'><p>Estimado " + nombreColaborador + ",</p>" +
                "<p>El pago correspondiente a la colaboración de la propuesta <strong>" + tituloPropuesta + "</strong> " +
                "realizada por <strong>" + nombreProponente + "</strong> ha sido registrado exitosamente.</p>" +
                "<div class='details'><h3>Detalles de la Colaboración</h3>" +
                "<p><strong>Propuesta:</strong> " + tituloPropuesta + "</p>" +
                "<p><strong>Proponente:</strong> " + nombreProponente + "</p>" +
                "<p><strong>Colaborador:</strong> " + nombreColab + "</p>" +
                "<p><strong>Monto:</strong> $" + String.format("%.2f", monto) + "</p>" +
                "<p><strong>Fecha de pago:</strong> " + fechaPagoStr + "</p></div>" +
                "<p><a href='" + urlConstancia + "' class='button'>Emitir Constancia de Pago</a></p>" +
                "<div class='footer'><p>Gracias por preferirnos,<br>Saludos.<br>Culturarte.</p></div></div></div></body></html>";
    }


    private String generarCuerpoEmailProponente(String nombreProponente, String tituloPropuesta,
                                                String nombreColab, Double monto, String fechaPagoStr) {
        return "<!DOCTYPE html>" +
                "<html><head><meta charset='UTF-8'>" +
                "<style>" +
                "body{font-family:Arial,sans-serif;line-height:1.6;color:#333;}" +
                ".container{max-width:600px;margin:0 auto;padding:20px;}" +
                ".header{background-color:#4CAF50;color:white;padding:20px;text-align:center;}" +
                ".content{padding:20px;background-color:#f9f9f9;}" +
                ".details{background-color:white;padding:15px;margin:15px 0;border-left:4px solid #4CAF50;}" +
                ".footer{text-align:center;margin-top:20px;padding:20px;color:#666;}" +
                "</style></head>" +
                "<body><div class='container'><div class='header'><h1>Culturarte</h1></div>" +
                "<div class='content'><p>Estimado " + nombreProponente + ",</p>" +
                "<p>El pago correspondiente a la colaboración de la propuesta <strong>" + tituloPropuesta + "</strong> " +
                "ha sido registrado exitosamente.</p>" +
                "<div class='details'><h3>Detalles de la Colaboración</h3>" +
                "<p><strong>Propuesta:</strong> " + tituloPropuesta + "</p>" +
                "<p><strong>Colaborador:</strong> " + nombreColab + "</p>" +
                "<p><strong>Monto:</strong> $" + String.format("%.2f", monto) + "</p>" +
                "<p><strong>Fecha de pago:</strong> " + fechaPagoStr + "</p></div>" +
                "<div class='footer'><p>Gracias por preferirnos,<br>Saludos.<br>Culturarte.</p></div></div></div></body></html>";
    }

    private void enviarEmail(String emailDestinatario, String asunto, String cuerpo) throws MessagingException {
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(emailDestinatario));
            message.setSubject(asunto);
            message.setContent(cuerpo, "text/html; charset=UTF-8");
            Transport.send(message);
        } catch (Exception e) {
            System.err.println("Error al enviar email: " + e.getMessage());
            throw new MessagingException("Error al enviar email: " + e.getMessage(), e);
        }
    }
}
