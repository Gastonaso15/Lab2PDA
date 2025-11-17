package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaUsuario;
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

                    // Leer los bytes de la imagen
                    byte[] imagenBytes;
                    try (java.io.InputStream is = imagenPart.getInputStream();
                         java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream()) {
                        byte[] buffer = new byte[8192];
                        int bytesRead;
                        while ((bytesRead = is.read(buffer)) != -1) {
                            baos.write(buffer, 0, bytesRead);
                        }
                        imagenBytes = baos.toByteArray();
                    }
                    
                    // Subir la imagen al servidor central usando el Web Service
                    culturarte.servicios.cliente.imagenes.ImagenWSEndpointService imagenServicio = 
                        new culturarte.servicios.cliente.imagenes.ImagenWSEndpointService();
                    culturarte.servicios.cliente.imagenes.IImagenControllerWS imagenWS = 
                        imagenServicio.getImagenWSEndpointPort();
                    
                    imagenBase64 = imagenWS.subirImagen(imagenBytes, nombreArchivo, "usuario");
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
        }
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate fechaNac = LocalDate.parse(fechaNacimiento, formatter);

            DtUsuario usuario;
            
            if ("PROPONENTE".equals(tipoUsuario)) {
                usuario = new DtProponente();
                usuario.setNickname(nickname);
                usuario.setNombre(nombre);
                usuario.setApellido(apellido);
                usuario.setPassword(password);
                usuario.setCorreo(email);
                usuario.setFechaNacimiento(WSFechaUsuario.toWSLocalDateWS(fechaNac));
                usuario.setImagen(imagenBase64);
                ((DtProponente) usuario).setDireccion(direccion);
                ((DtProponente) usuario).setBio(biografia);
                ((DtProponente) usuario).setSitioWeb(sitioWeb);
            } else {
                usuario = new DtColaborador();
                usuario.setNickname(nickname);
                usuario.setNombre(nombre);
                usuario.setApellido(apellido);
                usuario.setPassword(password);
                usuario.setCorreo(email);
                usuario.setFechaNacimiento(WSFechaUsuario.toWSLocalDateWS(fechaNac));
                usuario.setImagen(imagenBase64);
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
