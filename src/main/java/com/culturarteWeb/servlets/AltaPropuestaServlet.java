package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.IPropuestaControllerWS;
import culturarte.servicios.cliente.propuestas.ListaDTCategoria;
import culturarte.servicios.cliente.propuestas.ListaStrings;
import culturarte.servicios.cliente.propuestas.PropuestaWSEndpointService;
import culturarte.servicios.cliente.usuario.DtUsuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/altaPropuesta")

@MultipartConfig // necesario para req.getPart(...)
public class AltaPropuestaServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            PropuestaWSEndpointService servicio = new PropuestaWSEndpointService();
            IPC = servicio.getPropuestaWSEndpointPort();
        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    //pido los datos a altaPropuesta.jsp con el doGet
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

        String imagen = null;

        // --- Subida de imagen (opcional para el usuario) ---
        Part part = null;
        try {
            part = req.getPart("imagen"); // si no sube nada, getPart existe pero size=0
        } catch (IllegalStateException ise) {
            part = null; // defensivo si el form no viene multipart
        }

        if (part != null && part.getSize() > 0) {
            String type = part.getContentType();
            if (type == null || !type.startsWith("image/"))
                throw new IllegalArgumentException("El archivo no es una imagen válida.");

            // elegir extensión fiable
            String ext;
            if (type.contains("png")) ext = ".png";
            else if (type.contains("gif")) ext = ".gif";
            else if (type.contains("jpeg")) ext = ".jpeg";
            else ext = ".jpg";

            String relDir = "uploads/propuestas";
            String fileName = "ImagenProp" + System.currentTimeMillis() + ext;

            File base = new File(getServletContext().getRealPath("/"), relDir);
            if (!base.exists() && !base.mkdirs())
                throw new IOException("No se pudo crear el directorio de subida.");

            File dest = new File(base, fileName);
            part.write(dest.getAbsolutePath());

            imagen = relDir + "/" + fileName; // guardar RUTA RELATIVA
        }

        String categoria     = req.getParameter("categoria");
        String titulo        = req.getParameter("titulo");
        String descripcion   = req.getParameter("descripcion");
        String lugar         = req.getParameter("lugar");
        String fechaStr      = req.getParameter("fecha");
        String precioStr     = req.getParameter("precioEntrada");
        String montoStr      = req.getParameter("montoNecesario");
        //String imagen        = req.getParameter("imagen");
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


            /*  Estuve debuggeando y lo dejo por si lo preciso de nuevo
            System.out.println("Titulo: " + titulo);
            System.out.println("Descripcion: " + descripcion);
            System.out.println("Lugar: " + lugar);
            System.out.println("Fecha string: " + fechaStr); // Debugging line
            System.out.println("Precio: " + precio);
            System.out.println("Monto: " + monto);
            System.out.println("Imagen: " + imagen);
            System.out.println("Proponente: " + proponente.getNickname());
            System.out.println("Categoria: " + categoria);
            System.out.println("Retornos: " + retornos);
            */
            //Creo la propuesta

            IPC.crearPropuesta(titulo, descripcion, lugar, WSFechaPropuesta.toWSLocalDate(fecha), precio, monto, imagen,
                    proponente.getNickname(), categoria, listaRetornos);

            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception e) {
            e.printStackTrace(); // <-- imprime el error completo en la consola del servidor
            ListaDTCategoria categoriasWS;
            try {
                categoriasWS = IPC.devolverTodasLasCategorias();
                req.setAttribute("categorias", categoriasWS.getCategoria());
            } catch (Exception ex) {

            }
            req.setAttribute("error", "Error al crear la propuesta: " + e.getMessage());
            req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
        }
    }
}