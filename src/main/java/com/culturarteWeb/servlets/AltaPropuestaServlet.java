package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTCategoria;
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

        HttpSession ses = req.getSession(false);
        DTUsuario u = (ses != null) ? (DTUsuario) ses.getAttribute("usuarioLogueado") : null;
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/inicioDeSesion"); // o la página que uses
            return;
        }
        List<DTCategoria> categorias = IPC.devolverTodasLasCategorias();


        req.setAttribute("categorias", categorias);

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

        String categoria     = req.getParameter("categoria");
        String titulo        = req.getParameter("titulo");
        String descripcion   = req.getParameter("descripcion");
        String lugar         = req.getParameter("lugar");
        String fechaStr      = req.getParameter("fecha");
        String precioStr     = req.getParameter("precioEntrada");
        String montoStr      = req.getParameter("montoNecesario");
        String imagen        = req.getParameter("imagen");
        String[] retornosArr = req.getParameterValues("retornos");

        try {
            LocalDate fecha = LocalDate.parse(fechaStr);
            Double precio = Double.parseDouble(precioStr);
            Double monto = Double.parseDouble(montoStr);

            List<String> retornos = (retornosArr != null)
                    ? Arrays.asList(retornosArr)
                    : new ArrayList<>();
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

            IPC.crearPropuesta(
                    titulo,
                    descripcion,
                    lugar,
                    fecha,
                    precio,
                    monto,
                    imagen,
                    proponente.getNickname(),
                    categoria,
                    retornos
            );

            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception e) {
            e.printStackTrace(); // <-- imprime el error completo en la consola del servidor
            List<DTCategoria> categorias = IPC.devolverTodasLasCategorias();
            req.setAttribute("categorias", categorias);
            req.setAttribute("error", "Error al crear la propuesta: " + e.getMessage());
            req.getRequestDispatcher("/altaPropuesta.jsp").forward(req, resp);
        }
    }
}
