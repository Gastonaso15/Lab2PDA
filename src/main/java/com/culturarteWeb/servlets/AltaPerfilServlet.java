package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.DtProponente;
import culturarte.servicios.cliente.usuario.DtColaborador;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Base64;

@WebServlet("/altaPerfil")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)

public class AltaPerfilServlet extends HttpServlet {

    private IUsuarioControllerWS IUC;

    @Override
    public void init() throws ServletException {
        try {
            UsuarioWSEndpointService servicio = new UsuarioWSEndpointService();
            IUC = servicio.getUsuarioWSEndpointPort();
        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/altaPerfil.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nickname = request.getParameter("nickname");
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String fechaNacimiento = request.getParameter("fechaNacimiento");
        String tipoUsuario = request.getParameter("tipoUsuario");
        String direccion = request.getParameter("direccion");
        String biografia = request.getParameter("biografia");
        String sitioWeb = request.getParameter("sitioWeb");
        Part imagenPart = request.getPart("imagen");
        String imagenBase64 = null;

        String error = validarCampos(nickname, nombre, apellido, password, confirmPassword, 
                                   email, fechaNacimiento, tipoUsuario, direccion);
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("nickname", nickname);
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("fechaNacimiento", fechaNacimiento);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.setAttribute("direccion", direccion);
            request.setAttribute("biografia", biografia);
            request.setAttribute("sitioWeb", sitioWeb);
            request.getRequestDispatcher("/altaPerfil.jsp").forward(request, response);
            return;
        }

        if (imagenPart != null && imagenPart.getSize() > 0) {
            try {
                String contentType = imagenPart.getContentType();
                if (contentType != null && contentType.startsWith("image/")) {
                    String extension = "";
                    if (contentType.contains("jpeg") || contentType.contains("jpg")) {
                        extension = ".jpg";
                    } else if (contentType.contains("png")) {
                        extension = ".png";
                    } else if (contentType.contains("gif")) {
                        extension = ".gif";
                    } else {
                        extension = ".jpg";
                    }
                    
                    String nombreArchivo = "ImagenUP" + System.currentTimeMillis() + extension;
                    String rutaRelativa = "uploads/usuarios/" + nombreArchivo;

                    String rutaCompleta = getServletContext().getRealPath("/") + rutaRelativa;
                    imagenPart.write(rutaCompleta);
                    
                    imagenBase64 = rutaRelativa; // Ahora guardamos la ruta, no Base64
                } else {
                    request.setAttribute("error", "El archivo seleccionado no es una imagen válida");
                    request.setAttribute("nickname", nickname);
                    request.setAttribute("nombre", nombre);
                    request.setAttribute("apellido", apellido);
                    request.setAttribute("email", email);
                    request.setAttribute("fechaNacimiento", fechaNacimiento);
                    request.setAttribute("tipoUsuario", tipoUsuario);
                    request.setAttribute("direccion", direccion);
                    request.setAttribute("biografia", biografia);
                    request.setAttribute("sitioWeb", sitioWeb);
                    request.getRequestDispatcher("/altaPerfil.jsp").forward(request, response);
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("error", "Error al procesar la imagen: " + e.getMessage());
                request.getRequestDispatcher("/altaPerfil.jsp").forward(request, response);
                return;
            }
        }
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate fechaNac = LocalDate.parse(fechaNacimiento, formatter);

            DtUsuario usuario;
            
            if ("PROPONENTE".equals(tipoUsuario)) {
                usuario = new DtProponente(
                    nickname, nombre, apellido, password, email, 
                    fechaNac, imagenBase64, direccion, biografia, sitioWeb
                );
            } else {
                usuario = new DtColaborador(
                    nickname, nombre, apellido, password, email, 
                    fechaNac, imagenBase64
                );
            }

            IUC.crearUsuario(usuario);
            
            request.setAttribute("mensaje", "Usuario creado exitosamente");
            response.sendRedirect(request.getContextPath());
        } catch (DateTimeParseException e) {
            request.setAttribute("error", "Formato de fecha inválido");
            request.setAttribute("nickname", nickname);
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("fechaNacimiento", fechaNacimiento);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.setAttribute("direccion", direccion);
            request.setAttribute("biografia", biografia);
            request.setAttribute("sitioWeb", sitioWeb);
            request.getRequestDispatcher("/altaPerfil.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al crear usuario: " + e.getMessage());
            request.setAttribute("nickname", nickname);
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("fechaNacimiento", fechaNacimiento);
            request.setAttribute("tipoUsuario", tipoUsuario);
            request.setAttribute("direccion", direccion);
            request.setAttribute("biografia", biografia);
            request.setAttribute("sitioWeb", sitioWeb);
            request.getRequestDispatcher("/altaPerfil.jsp").forward(request, response);
        }
    }
    
    private String validarCampos(String nickname, String nombre, String apellido, 
                                String password, String confirmPassword, String email, 
                                String fechaNacimiento, String tipoUsuario, String direccion) {

        if (nickname == null || nickname.trim().isEmpty()) {
            return "El nickname es obligatorio";
        }
        if (nombre == null || nombre.trim().isEmpty()) {
            return "El nombre es obligatorio";
        }
        if (apellido == null || apellido.trim().isEmpty()) {
            return "El apellido es obligatorio";
        }
        if (password == null || password.trim().isEmpty()) {
            return "La contraseña es obligatoria";
        }
        if (email == null || email.trim().isEmpty()) {
            return "El correo electrónico es obligatorio";
        }
        if (fechaNacimiento == null || fechaNacimiento.trim().isEmpty()) {
            return "La fecha de nacimiento es obligatoria";
        }
        if (tipoUsuario == null || tipoUsuario.trim().isEmpty()) {
            return "Debe seleccionar un tipo de usuario";
        }
        if (!password.equals(confirmPassword)) {
            return "Las contraseñas no coinciden";
        }
        if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            return "Formato de correo electrónico inválido";
        }
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate fechaNac = LocalDate.parse(fechaNacimiento, formatter);
            LocalDate hoy = LocalDate.now();
            if (fechaNac.isAfter(hoy)) {
                return "La fecha de nacimiento no puede ser futura";
            }
            if (fechaNac.isBefore(hoy.minusYears(120))) {
                return "La fecha de nacimiento no puede ser anterior a hace 120 años";
            }
        } catch (DateTimeParseException e) {
            return "Formato de fecha inválido";
        }
        if ("PROPONENTE".equals(tipoUsuario)) {
            if (direccion == null || direccion.trim().isEmpty()) {
                return "La dirección es obligatoria para Proponentes";
            }
        }
        return null;
    }
}
