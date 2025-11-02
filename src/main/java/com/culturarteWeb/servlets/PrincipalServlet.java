package com.culturarteWeb.servlets;
import com.culturarteWeb.util.LocalDateAdaptor;
import com.culturarteWeb.util.WSConsumer;
import com.culturarteWeb.ws.propuestas.*;
import com.culturarteWeb.ws.usuarios.IUsuarioControllerWS;
import com.culturarteWeb.ws.usuarios.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/principal")
public class PrincipalServlet extends HttpServlet {
    IPropuestaControllerWS IPC = WSConsumer.get().propuestas();
    IUsuarioControllerWS ICU = WSConsumer.get().usuarios();

    @Override
    public void init() throws  ServletException {
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try{
            //verificarVencimientosAutomaticamente();
            
            String estadoFiltro = request.getParameter("estado");
            String busqueda = request.getParameter("busqueda");

            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            List<DtPropuesta> propuestasVisibles = new ArrayList<>();

            for (DtPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA) {
                    boolean cumpleEstado = false;
                    
                    if (estadoFiltro == null || estadoFiltro.isEmpty() || "todas".equals(estadoFiltro)) {
                        cumpleEstado = true;
                    } else {
                        cumpleEstado = coincideConEstadoFiltro(propuesta.getEstadoActual().toString(), estadoFiltro);
                    }

                    boolean cumpleBusqueda = true;
                    if (busqueda != null && !busqueda.trim().isEmpty()) {
                        cumpleBusqueda = coincideConBusqueda(propuesta, busqueda.trim());
                    }

                    if (cumpleEstado && cumpleBusqueda) {
                        propuestasVisibles.add(propuesta);
                    }
                }
            }

            boolean esProponente = false;
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("usuarioLogueado") != null) {
                DtUsuario usuarioLogueado = (DtUsuario) session.getAttribute("usuarioLogueado");
                try {
                    ICU.devolverProponentePorNickname(usuarioLogueado.getNickname());
                    esProponente = true;
                } catch (Exception e) {
                    esProponente = false;
                }
            }

            boolean esColaborador = false;
            if (session != null && session.getAttribute("usuarioLogueado") != null) {
                DtUsuario usuarioLogueado = (DtUsuario) session.getAttribute("usuarioLogueado");
                try {
                    ICU.devolverProponentePorNickname(usuarioLogueado.getNickname());
                    esColaborador = false;
                } catch (Exception e) {
                    esColaborador = true;
                }
            }

            List<PropuestaConDatos> propuestasConDatos = new ArrayList<>();
            for (DtPropuesta propuesta : propuestasVisibles) {
                PropuestaConDatos propuestaConDatos = calcularDatosPropuesta(propuesta);
                propuestasConDatos.add(propuestaConDatos);
            }
            
            List<DtCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
            request.setAttribute("categorias", categorias);
            request.setAttribute("propuestas", propuestasConDatos);
            request.setAttribute("estadoFiltro", estadoFiltro);
            request.setAttribute("busqueda", busqueda);
            request.setAttribute("esProponente", esProponente);
            request.setAttribute("esColaborador", esColaborador);
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la página principal: " + e.getMessage());
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }
    }

    private List<DtCategoria> extraerCategoriasReales(List<DtPropuesta> propuestas) {
        List<DtCategoria> categorias = new ArrayList<>();
        java.util.Map<String, DtCategoria> categoriasMap = new java.util.LinkedHashMap<>();

        for(DtPropuesta propuesta : propuestas){
            try{
                if(propuesta.getCategoria() != null){
                    DtCategoria categoria = propuesta.getCategoria();
                    String nombreCategoria = categoria.getNombre();
                    if(!categoriasMap.containsKey(nombreCategoria)){
                        categoriasMap.put(nombreCategoria, categoria);
                    }
                }
            } catch (Exception e) {
                System.out.println("Error al obtener categoría de propuesta: " + e.getMessage());
            }
        }

        categorias.addAll(categoriasMap.values());

        if(categorias.isEmpty()){
            String[] categoriasDefault = {"Música", "Teatro", "Danza", "Artes Visuales", "Literatura", "Cine"};
            for(String categoriaDefault : categoriasDefault){
                try{
                    DtCategoria categoria = DtCategoria.class.getDeclaredConstructor(String.class).newInstance(categoriaDefault);
                    categorias.add(categoria);
                } catch (Exception e) {
                    System.out.println("No se pudo crear categoría por defecto: "+ categoriaDefault);
                }
            }
        }
        return categorias;
    }

    private boolean coincideConBusqueda(DtPropuesta propuesta, String busqueda) {
        if (busqueda == null || busqueda.trim().isEmpty()) {
            return true;
        }
        
        String busquedaLower = busqueda.toLowerCase();

        if (propuesta.getTitulo() != null && 
            propuesta.getTitulo().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        if (propuesta.getDescripcion() != null &&
            propuesta.getDescripcion().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        if (propuesta.getLugar() != null && 
            propuesta.getLugar().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        if (propuesta.getDTProponente() != null && 
            propuesta.getDTProponente().getNickname() != null &&
            propuesta.getDTProponente().getNickname().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        if (propuesta.getCategoria() != null && 
            propuesta.getCategoria().getNombre() != null &&
            propuesta.getCategoria().getNombre().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        return false;
    }

    private boolean coincideConEstadoFiltro(String estadoPropuesta, String filtro) {
        if (filtro == null || estadoPropuesta == null) {
            return false;
        }
        switch (filtro.toLowerCase()) {
            case "en_financiacion":
                return estadoPropuesta.toUpperCase().contains("FINANCIACION") ||
                        estadoPropuesta.toUpperCase().contains("EN_FINANCIACION");
            case "financiadas":
                return estadoPropuesta.toUpperCase().contains("FINANCIADA");
            case "no_financiadas":
                return estadoPropuesta.toUpperCase().contains("NO_FINANCIADA") ||
                        estadoPropuesta.toUpperCase().contains("NO FINANCIADA");
            case "canceladas":
                return estadoPropuesta.toUpperCase().contains("CANCELADA");
            default:
                return false;
        }
    }

    private PropuestaConDatos calcularDatosPropuesta(DtPropuesta propuesta) {
        double montoRecaudado = 0.0;
        int totalColaboradores = 0;
        long diasRestantes = 0;

        if (propuesta.getColaboraciones() != null) {
            for (DtColaboracion colaboracion : propuesta.getColaboraciones()) {
                montoRecaudado += colaboracion.getMonto();
            }
            totalColaboradores = propuesta.getColaboraciones().size();
        }

        try {
            if (propuesta.getFechaPublicacion() != null) {
                var fechaString = propuesta.getFechaPublicacion();                          // String del tipo "02-11-2025"
                LocalDate fechaPublicacion = LocalDateAdaptor.parseOrNull(fechaString);     //Ahora sí en formato LocalDate
                LocalDate fechaActual = LocalDate.now();

                LocalDate fechaLimite = fechaPublicacion.plusDays(30);
                
                diasRestantes = ChronoUnit.DAYS.between(fechaActual, fechaLimite);
                if (diasRestantes < 0) {
                    diasRestantes = 0;
                }
            }
        } catch (Exception e) {
            System.out.println("Error al calcular días restantes: " + e.getMessage());
            diasRestantes = 0;
        }

        return new PropuestaConDatos(propuesta, montoRecaudado, totalColaboradores, diasRestantes);
    }

    public static class PropuestaConDatos {
        private DtPropuesta propuesta;
        private double montoRecaudado;
        private int totalColaboradores;
        private long diasRestantes;
        
        public PropuestaConDatos(DtPropuesta propuesta, double montoRecaudado, int totalColaboradores, long diasRestantes) {
            this.propuesta = propuesta;
            this.montoRecaudado = montoRecaudado;
            this.totalColaboradores = totalColaboradores;
            this.diasRestantes = diasRestantes;
        }
        
        public DtPropuesta getPropuesta() { return propuesta; }
        public double getMontoRecaudado() { return montoRecaudado; }
        public int getTotalColaboradores() { return totalColaboradores; }
        public long getDiasRestantes() { return diasRestantes; }
    }

/*
    private void verificarVencimientosAutomaticamente() {
        try {
            //PropuestaManejador pm = IPC.getPropuestaManejador()
            //com.culturarte.logica.manejadores.PropuestaManejador pm = culturarte.logica.manejadores.PropuestaManejador.getInstance();
            ListaDTPropuesta ListaPropWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = ListaPropWS.getPropuesta();

            java.time.LocalDate fechaActual = java.time.LocalDate.now();
            
            for (DtPropuesta dtPropuesta : todasLasPropuestas) {
                DtPropuesta propuesta = IPC.obtenerPropuestaPorTitulo(dtPropuesta.getTitulo());
                if (propuesta != null &&

                    (propuesta.getEstadoActual() == DtEstadoPropuesta.PUBLICADA ||
                     propuesta.getEstadoActual() == DtEstadoPropuesta.EN_FINANCIACION)) {

                    if (propuesta.getFechaPublicacion() != null) {
                        java.time.LocalDate fechaVencimiento = propuesta.getFechaPublicacion().plusDays(30);
                        
                        if (fechaActual.isAfter(fechaVencimiento)) {
                            double montoRecaudado = calcularMontoRecaudado(dtPropuesta);
                            double montoNecesario = dtPropuesta.getMontoNecesario();
                            
                            if (montoRecaudado >= montoNecesario) {
                                propuesta.setEstadoActual(DtEstadoPropuesta.FINANCIADA);
                                propuesta.agregarPropuestaEstado(new culturarte.logica.modelos.PropuestaEstado(
                                    propuesta, culturarte.logica.modelos.EstadoPropuesta.FINANCIADA, fechaActual));
                                
                                System.out.println("Propuesta '" + propuesta.getTitulo() + 
                                    "' transicionada a FINANCIADA automáticamente (monto recaudado: $" + montoRecaudado + 
                                    ", monto necesario: $" + montoNecesario + ")");
                                
                            } else {
                                propuesta.setEstadoActual(culturarte.logica.modelos.EstadoPropuesta.NO_FINANCIADA);
                                propuesta.agregarPropuestaEstado(new culturarte.logica.modelos.PropuestaEstado(
                                    propuesta, culturarte.logica.modelos.EstadoPropuesta.NO_FINANCIADA, fechaActual));
                                
                                System.out.println("Propuesta '" + propuesta.getTitulo() + 
                                    "' transicionada a NO_FINANCIADA automáticamente (monto recaudado: $" + montoRecaudado + 
                                    ", monto necesario: $" + montoNecesario + ")");
                            }
                            
                            pm.actualizarPropuesta(propuesta);
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error al verificar vencimientos automáticamente: " + e.getMessage());
            e.printStackTrace();
        }
    }
*/
    private double calcularMontoRecaudado(DtPropuesta propuesta) {
        double montoTotal = 0.0;
        
        if (propuesta.getColaboraciones() != null) {
            for (var colaboracion : propuesta.getColaboraciones()) {
                montoTotal += colaboracion.getMonto();
            }
        }
        
        return montoTotal;
    }

}


