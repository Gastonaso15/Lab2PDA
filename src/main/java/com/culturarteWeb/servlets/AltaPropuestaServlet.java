package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.IPropuestaControllerWS;
import culturarte.servicios.cliente.propuestas.ListaDTCategoria;
import culturarte.servicios.cliente.propuestas.ListaStrings;
import culturarte.servicios.cliente.propuestas.PropuestaWSEndpointService;
import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/altaPropuesta")

@MultipartConfig
public class AltaPropuestaServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            System.setProperty("com.sun.xml.ws.transport.http.client.HttpTransportPipe.dump", "true");
            System.setProperty("com.sun.xml.internal.ws.transport.http.client.HttpTransportPipe.dump", "true");

            PropuestaWSEndpointService servicio = new PropuestaWSEndpointService();
            IPC = servicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();
        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession ses = req.getSession(false);
        DtUsuario u = (ses != null) ? (DtUsuario) ses.getAttribute("usuarioLogueado") : null;
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/inicioDeSesion");
            return;
        }

        try {
            ListaDTCategoria categoriasWS = IPC.devolverTodasLasCategorias();
            req.setAttribute("categorias", categoriasWS.getCategoria());
        } catch (Exception e) {
            throw new ServletException("No se pudieron obtener las categorías", e);
        }

        boolean esColaboradorActual = false;
        boolean esProponenteActual = true;
        try {
            ICU.devolverColaboradorPorNickname(u.getNickname());
            esColaboradorActual = true;
        } catch (Exception e) {
            esColaboradorActual = false;
        }
        req.setAttribute("esProponente", esProponenteActual);
        req.setAttribute("esColaborador", esColaboradorActual);

        req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession ses = req.getSession(false);
        DtUsuario proponente = (ses != null) ? (DtUsuario) ses.getAttribute("usuarioLogueado") : null;
        if (proponente == null) {
            resp.sendRedirect(req.getContextPath() + "/inicioDeSesion");
            return;
        }

        String imagen = "";
        Part part = null;
        try {
            part = req.getPart("imagen");
        } catch (IllegalStateException ise) {
            part = null; // por si el form no vino multipart (defensivo)
        }

        if (part != null && part.getSize() > 0) {
            String type = part.getContentType();
            if (type == null || !type.startsWith("image/")) {
                throw new IllegalArgumentException("El archivo no es una imagen válida.");
            }

            String ext;
            if (type.contains("png"))       ext = ".png";
            else if (type.contains("gif"))  ext = ".gif";
            else if (type.contains("jpeg")) ext = ".jpeg";
            else                            ext = ".jpg";

            String relDir = "uploads/propuestas";
            String fileName = "ImagenProp" + System.currentTimeMillis() + ext;

            File base = new File(getServletContext().getRealPath("/"), relDir);
            if (!base.exists() && !base.mkdirs()) {
                throw new IOException("No se pudo crear el directorio de subida.");
            }

            File dest = new File(base, fileName);
            part.write(dest.getAbsolutePath());

            imagen = relDir + "/" + fileName;
        }

        String categoria     = req.getParameter("categoria");
        String titulo        = req.getParameter("titulo");
        String descripcion   = req.getParameter("descripcion");
        String lugar         = req.getParameter("lugar");
        String fechaStr      = req.getParameter("fecha");
        String precioStr     = req.getParameter("precioEntrada");
        String montoStr      = req.getParameter("montoNecesario");
        String[] retornosArr = req.getParameterValues("retornos");

        try {
            java.time.LocalDate fecha = java.time.LocalDate.parse(fechaStr);
            Double precio = Double.parseDouble(precioStr);
            Double monto = Double.parseDouble(montoStr);



            if (fecha.isBefore(java.time.LocalDate.now())) {
                ListaDTCategoria categoriasWS = IPC.devolverTodasLasCategorias();
                req.setAttribute("categorias", categoriasWS.getCategoria());
                req.setAttribute("error", "La fecha no puede ser anterior a la actual");

                req.setAttribute("categoria", categoria);
                req.setAttribute("titulo", titulo);
                req.setAttribute("descripcion", descripcion);
                req.setAttribute("lugar", lugar);
                req.setAttribute("fecha", fechaStr);
                req.setAttribute("precioEntrada", precioStr);
                req.setAttribute("montoNecesario", montoStr);
                req.setAttribute("retornos", retornosArr);
                req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
                return;
            }

            List<String> retornos = (retornosArr != null) ? Arrays.asList(retornosArr) : new ArrayList<>();
            ListaStrings listaRetornos = new ListaStrings();
            listaRetornos.getItem().addAll(retornos);
            IPC.crearPropuesta(titulo, descripcion, lugar, WSFechaPropuesta.toWSLocalDateWS(fecha), precio, monto, imagen,
                    proponente.getNickname(), categoria, listaRetornos);

            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception e) {
            e.printStackTrace(); // <-- imprime el error completo en la consola del servidor
            try {
                ListaDTCategoria categoriasWS = IPC.devolverTodasLasCategorias();
                req.setAttribute("categorias", categoriasWS.getCategoria());
            } catch (Exception ignore) {
            }

            req.setAttribute("error", (e.getMessage() != null) ? e.getMessage() : "Ocurrió un error procesando la propuesta");
            req.setAttribute("categoria", categoria);
            req.setAttribute("titulo", titulo);
            req.setAttribute("descripcion", descripcion);
            req.setAttribute("lugar", lugar);
            req.setAttribute("fecha", fechaStr);
            req.setAttribute("precioEntrada", precioStr);
            req.setAttribute("montoNecesario", montoStr);
            req.setAttribute("retornos", retornosArr);
            req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
            return;
        }
    }
}