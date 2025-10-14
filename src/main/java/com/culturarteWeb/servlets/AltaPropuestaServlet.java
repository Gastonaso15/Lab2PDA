package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.IUsuarioController;
import culturarte.logica.controladores.PropuestaController;
import culturarte.logica.controladores.UsuarioController;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.*;

@WebServlet("/altaPropuesta")
@MultipartConfig
public class AltaPropuestaServlet extends HttpServlet {

    private IUsuarioController ICU;
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        ICU = new UsuarioController();
        IPC = new PropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Debe estar logueado y ser Proponente
        HttpSession ses = req.getSession(false);
        DTUsuario u = (ses != null) ? (DTUsuario) ses.getAttribute("usuarioLogueado") : null;
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/inicioDeSesion"); // o la página que uses
            return;
        }
        // Si quisieras bloquear a Colaboradores, acá podrías verificar tipo.

        req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession ses = req.getSession(false);
        DTUsuario proponente = (ses != null) ? (DTUsuario) ses.getAttribute("usuarioLogueado") : null;
        if (proponente == null) {
            resp.sendRedirect(req.getContextPath() + "/inicioDeSesion");
            return;
        }

        // 1) Leer campos
        String categoria     = trim(req.getParameter("categoria"));
        String titulo        = trim(req.getParameter("titulo"));
        String descripcion   = trim(req.getParameter("descripcion"));
        String lugar         = trim(req.getParameter("lugar"));
        String fechaStr      = trim(req.getParameter("fecha"));
        String precioStr     = trim(req.getParameter("precioEntrada"));
        String montoStr      = trim(req.getParameter("montoNecesario"));
        String[] retornosArr = req.getParameterValues("retornos");

        // 2) Validaciones server-side básicas
        List<String> errores = new ArrayList<>();
        if (isEmpty(categoria))   errores.add("Seleccioná una categoría.");
        if (isEmpty(titulo))      errores.add("El título es obligatorio.");
        if (isEmpty(descripcion)) errores.add("La descripción es obligatoria.");
        if (isEmpty(lugar))       errores.add("El lugar es obligatorio.");
        LocalDate fecha = null;
        try {
            fecha = LocalDate.parse(fechaStr);
            if (fecha.isBefore(LocalDate.now())) errores.add("La fecha debe ser hoy o posterior.");
        } catch (Exception e) {
            errores.add("Fecha inválida (formato AAAA-MM-DD).");
        }
        float precioEntrada = parseFloat(precioStr, -1f);
        if (precioEntrada <= 0) errores.add("El precio de la entrada debe ser mayor a 0.");

        float montoNecesario = parseFloat(montoStr, -1f);
        if (montoNecesario <= 0) errores.add("El monto necesario debe ser mayor a 0.");

        List<String> retornos = new ArrayList<>();
        if (retornosArr != null) retornos.addAll(Arrays.asList(retornosArr));
        if (retornos.isEmpty()) errores.add("Seleccioná al menos un tipo de retorno.");

        // 3) Subida de imagen (opcional)
        Part imagenPart = null;
        String imagenPathRelativa = null;
        try {
            imagenPart = req.getPart("imagen");
            if (imagenPart != null && imagenPart.getSize() > 0) {
                String fileName = Path.of(imagenPart.getSubmittedFileName()).getFileName().toString();
                String ext = fileName.contains(".") ? fileName.substring(fileName.lastIndexOf('.')) : ".png";
                String nuevoNombre = "prop_" + System.currentTimeMillis() + ext;

                // Guardar dentro de /uploads del webapp
                String realUploads = req.getServletContext().getRealPath("/uploads");
                if (realUploads == null) {
                    // Fallback: crear carpeta dentro del contenedor temporal
                    realUploads = req.getServletContext().getRealPath("/") + "uploads";
                }
                Files.createDirectories(Path.of(realUploads));
                Path destino = Path.of(realUploads, nuevoNombre);
                try (InputStream in = imagenPart.getInputStream()) {
                    Files.copy(in, destino);
                }
                imagenPathRelativa = req.getContextPath() + "/uploads/" + nuevoNombre;
            }
        } catch (Exception e) {
            errores.add("No se pudo procesar la imagen: " + e.getMessage());
        }

        if (!errores.isEmpty()) {
            req.setAttribute("errores", errores);
            req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
            return;
        }

        // 4) Llamar a la lógica.
        try {

            //DESPUES VEO CUAL ES MAS EFICIENTE
            /*

            Opción 1: un unico met odo
            IPC.altaPropuesta(proponente.getNickname(), categoria, titulo, descripcion, lugar, fecha, precioEntrada, montoNecesario, retornos, imagenPathRelativa);

            2 Opción 2: construir DTO y pasarlo
            DTPropuesta dto = new DTPropuesta();
            dto.setTitulo(titulo);
            dto.setDescripcion(descripcion);
            dto.setLugar(lugar);
            dto.setFechaEspectaculo(java.sql.Date.valueOf(fecha)); // si tu DTO usa Date; si usa LocalDate, setea directo
            dto.setPrecioEntrada(precioEntrada);
            dto.setMontoNecesario(montoNecesario);
            dto.setImagen(imagenPathRelativa); // ruta relativa accesible desde el web
            dto.setCategoria(categoria);
            // si tiene campo proponente:
            dto.setProponenteNickname(proponente.getNickname());
            // y si maneja retornos:
            */
            // ————————————————————————————————————————————————————————————————

            // 5) Redirigir a la consulta de propuesta (por título)
            resp.sendRedirect(req.getContextPath() + "/consultaPropuesta?titulo=" + encode(titulo));
        } catch (Exception e) {
            e.printStackTrace();
            errores.add("No se pudo crear la propuesta: " + e.getMessage());
            req.setAttribute("errores", errores);
            req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
        }
    }

    // Helpers
    private static String trim(String s) { return s == null ? null : s.trim(); }
    private static boolean isEmpty(String s) { return s == null || s.isBlank(); }
    private static float parseFloat(String s, float def) {
        try { return Float.parseFloat(s); } catch (Exception e) { return def; }
    }
    private static String encode(String s) {
        try { return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8); } catch (Exception e) { return s; }
    }
}
