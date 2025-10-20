package com.culturarteWeb.servlets;
import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTCategoria;
import culturarte.logica.DTs.DTEstadoPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.DTs.DTColaboracion;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import culturarte.logica.controladores.IUsuarioController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/principal")
public class PrincipalServlet extends HttpServlet {
    private IPropuestaController IPC;
    private IUsuarioController ICU;

    @Override
    public void init() throws  ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
        ICU = fabrica.getIUsuarioController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try{
            // Verificar vencimientos automáticamente cada vez que se accede a la página principal
            verificarVencimientosAutomaticamente();
            
            String estadoFiltro = request.getParameter("estado");
            String busqueda = request.getParameter("busqueda");
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasVisibles = new ArrayList<>();

            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA) {
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
                DTUsuario usuarioLogueado = (DTUsuario) session.getAttribute("usuarioLogueado");
                try {
                    ICU.devolverProponentePorNickname(usuarioLogueado.getNickname());
                    esProponente = true;
                } catch (Exception e) {
                    esProponente = false;
                }
            }

            boolean esColaborador = false;
            if (session != null && session.getAttribute("usuarioLogueado") != null) {
                DTUsuario usuarioLogueado = (DTUsuario) session.getAttribute("usuarioLogueado");
                try {
                    ICU.devolverProponentePorNickname(usuarioLogueado.getNickname());
                    esColaborador = false;
                } catch (Exception e) {
                    esColaborador = true;
                }
            }
            
            // Calcular datos adicionales para cada propuesta
            List<PropuestaConDatos> propuestasConDatos = new ArrayList<>();
            for (DTPropuesta propuesta : propuestasVisibles) {
                PropuestaConDatos propuestaConDatos = calcularDatosPropuesta(propuesta);
                propuestasConDatos.add(propuestaConDatos);
            }
            
            List<DTCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
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

    private List<DTCategoria> extraerCategoriasReales(List<DTPropuesta> propuestas) {
        List<DTCategoria> categorias = new ArrayList<>();
        java.util.Map<String, DTCategoria> categoriasMap = new java.util.LinkedHashMap<>();

        for(DTPropuesta propuesta : propuestas){
            try{
                if(propuesta.getCategoria() != null){
                    DTCategoria categoria = propuesta.getCategoria();
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
                    DTCategoria categoria = DTCategoria.class.getDeclaredConstructor(String.class).newInstance(categoriaDefault);
                    categorias.add(categoria);
                } catch (Exception e) {
                    System.out.println("No se pudo crear categoría por defecto: "+ categoriaDefault);
                }
            }
        }
        return categorias;
    }

    private boolean coincideConBusqueda(DTPropuesta propuesta, String busqueda) {
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

    private PropuestaConDatos calcularDatosPropuesta(DTPropuesta propuesta) {
        double montoRecaudado = 0.0;
        int totalColaboradores = 0;
        long diasRestantes = 0;
        
        // Calcular monto recaudado y total de colaboradores
        if (propuesta.getColaboraciones() != null) {
            for (DTColaboracion colaboracion : propuesta.getColaboraciones()) {
                montoRecaudado += colaboracion.getMonto();
            }
            totalColaboradores = propuesta.getColaboraciones().size();
        }
        
        // Calcular días restantes (30 días desde la fecha de publicación)
        try {
            if (propuesta.getFechaPublicacion() != null) {
                LocalDate fechaPublicacion = propuesta.getFechaPublicacion();
                LocalDate fechaActual = LocalDate.now();
                
                // Calcular la fecha límite (30 días después de la publicación)
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
        private DTPropuesta propuesta;
        private double montoRecaudado;
        private int totalColaboradores;
        private long diasRestantes;
        
        public PropuestaConDatos(DTPropuesta propuesta, double montoRecaudado, int totalColaboradores, long diasRestantes) {
            this.propuesta = propuesta;
            this.montoRecaudado = montoRecaudado;
            this.totalColaboradores = totalColaboradores;
            this.diasRestantes = diasRestantes;
        }
        
        public DTPropuesta getPropuesta() { return propuesta; }
        public double getMontoRecaudado() { return montoRecaudado; }
        public int getTotalColaboradores() { return totalColaboradores; }
        public long getDiasRestantes() { return diasRestantes; }
    }

    /**
     * Verifica automáticamente los vencimientos de financiación y procesa las transiciones de estado
     */
    private void verificarVencimientosAutomaticamente() {
        try {
            culturarte.logica.manejadores.PropuestaManejador pm = culturarte.logica.manejadores.PropuestaManejador.getInstance();
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            
            java.time.LocalDate fechaActual = java.time.LocalDate.now();
            
            for (DTPropuesta dtPropuesta : todasLasPropuestas) {
                culturarte.logica.modelos.Propuesta propuesta = pm.obtenerPropuestaPorTitulo(dtPropuesta.getTitulo());
                
                if (propuesta != null && 
                    (propuesta.getEstadoActual() == culturarte.logica.modelos.EstadoPropuesta.PUBLICADA || 
                     propuesta.getEstadoActual() == culturarte.logica.modelos.EstadoPropuesta.EN_FINANCIACION)) {
                    
                    // Verificar si ha vencido el plazo (30 días desde la fecha de publicación)
                    if (propuesta.getFechaPublicacion() != null) {
                        java.time.LocalDate fechaVencimiento = propuesta.getFechaPublicacion().plusDays(30);
                        
                        if (fechaActual.isAfter(fechaVencimiento)) {
                            // El plazo ha vencido, verificar si alcanzó el monto objetivo
                            double montoRecaudado = calcularMontoRecaudado(dtPropuesta);
                            double montoNecesario = dtPropuesta.getMontoNecesario();
                            
                            if (montoRecaudado >= montoNecesario) {
                                // Alcanzó el objetivo: cambiar a FINANCIADA
                                propuesta.setEstadoActual(culturarte.logica.modelos.EstadoPropuesta.FINANCIADA);
                                propuesta.agregarPropuestaEstado(new culturarte.logica.modelos.PropuestaEstado(
                                    propuesta, culturarte.logica.modelos.EstadoPropuesta.FINANCIADA, fechaActual));
                                
                                System.out.println("Propuesta '" + propuesta.getTitulo() + 
                                    "' transicionada a FINANCIADA automáticamente (monto recaudado: $" + montoRecaudado + 
                                    ", monto necesario: $" + montoNecesario + ")");
                                
                            } else {
                                // No alcanzó el objetivo: cambiar a NO_FINANCIADA
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

    /**
     * Calcula el monto total recaudado por una propuesta
     */
    private double calcularMontoRecaudado(DTPropuesta propuesta) {
        double montoTotal = 0.0;
        
        if (propuesta.getColaboraciones() != null) {
            for (var colaboracion : propuesta.getColaboraciones()) {
                montoTotal += colaboracion.getMonto();
            }
        }
        
        return montoTotal;
    }

}


