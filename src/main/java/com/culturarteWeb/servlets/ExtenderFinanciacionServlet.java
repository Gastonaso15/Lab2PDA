package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;

import culturarte.logica.controladores.IUsuarioController;
import culturarte.logica.manejadores.PropuestaManejador;
import culturarte.logica.modelos.Propuesta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/extenderFinanciacion")

public class ExtenderFinanciacionServlet extends HttpServlet {

    private IPropuestaController IPC;
    private IUsuarioController ICU;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        ICU = fabrica.getIUsuarioController();
        IPC = fabrica.getIPropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //averiguo si es proponente o no
        boolean esProponente = false;
        DTUsuario userProponente = null;
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuarioLogueado") != null) {
            DTUsuario user = (DTUsuario) session.getAttribute("usuarioLogueado");
            try {
                userProponente= ICU.devolverProponentePorNickname(user.getNickname());
                esProponente = true;
            } catch (Exception e) {
                esProponente = false;
            }
        }


        List<DTPropuesta> propuestas = IPC.devolverTodasLasPropuestas();

        List<DTPropuesta> propuestasActivas = new ArrayList<>();

        if (!esProponente || userProponente == null) {
            request.setAttribute("error", "Solo los proponentes pueden extender la financiacion de sus propuestas.");
            request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
            return;
        }

        for (DTPropuesta p : propuestas) {
            if(p.getProponente().equals(userProponente.getNickname())) {
                if ((p.getEstadoActual().toString().equals("EN_FINANCIACION")
                        || p.getEstadoActual().toString().equals("PUBLICADA"))) {
                    boolean activa = p.getFechaPublicacion().atStartOfDay()
                            .plusMonths(1)
                            .isAfter(LocalDateTime.now());
                    if (activa)
                        propuestasActivas.add(p);
                }
            }
        }

        request.setAttribute("propuestas", propuestasActivas);
        request.getRequestDispatcher("/extenderFinanciacion.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String propuestaSeleccionada = request.getParameter("propuestas");

        System.out.println("Propuesta seleccionada: " + propuestaSeleccionada);

        try {
            //Obtengo el usuario actual para poder trabajar con él
            HttpSession session = request.getSession(false);
            session.getAttribute("usuarioLogueado"); //esto funciona porque está codeado en InicioDeSesionServlet
            DTUsuario user = (DTUsuario) session.getAttribute("usuarioLogueado");

            //Obtengo la propuesta para poder trabajar con ella
            PropuestaManejador PM = PropuestaManejador.getInstance();
            Propuesta propuesta = PM.obtenerPropuestaPorTitulo(propuestaSeleccionada);
            System.out.println("Fecha Prevista Propuesta:" + propuesta.getFechaPrevista());

            IPC.extenderFinanciacion(user, propuestaSeleccionada);

            System.out.println("Fecha Prevista Propuesta:" +propuesta.getFechaPrevista());


            request.setAttribute("mensaje", "La financiación de la propuesta ha sido extendida exitosamente.");
        } catch (Exception e) {
            e.printStackTrace(); // <-- imprime el error completo en la consola del servidor
        }
        doGet(request, response);
    }
}