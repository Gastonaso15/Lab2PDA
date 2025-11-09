package com.culturarteWeb.servlets;
import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/principal")
public class PrincipalServlet extends HttpServlet {
    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

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
            verificarVencimientosAutomaticamente();
            
            String estadoFiltro = request.getParameter("estado");
            String busqueda = request.getParameter("busqueda");
            String categoriaFiltro = request.getParameter("categoria");
            String ordenarPor = request.getParameter("ordenarPor");

            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            List<DtPropuesta> propuestasVisibles = new ArrayList<>();

            for (DtPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA) {
                    boolean cumpleEstado = false;
                    boolean cumpleBusqueda = true;
                    boolean cumpleCategoria = true;
                    
                    if (estadoFiltro == null || estadoFiltro.isEmpty() || "todas".equals(estadoFiltro)) {
                        cumpleEstado = true;
                    } else {
                        cumpleEstado = coincideConEstadoFiltro(propuesta.getEstadoActual().toString(), estadoFiltro);
                    }

                    if (busqueda != null && !busqueda.trim().isEmpty()) {
                        cumpleBusqueda = coincideConBusqueda(propuesta, busqueda.trim());
                    }

                    if (categoriaFiltro != null && !categoriaFiltro.isEmpty() && !"todas".equals(categoriaFiltro)) {
                        cumpleCategoria = coincideConCategoriaFiltro(propuesta, categoriaFiltro);
                    }

                    if (cumpleEstado && cumpleBusqueda && cumpleCategoria) {
                        propuestasVisibles.add(propuesta);
                    }
                }
            }

            if (ordenarPor != null && !ordenarPor.isEmpty()) {
                propuestasVisibles = ordenarPropuestas(propuestasVisibles, ordenarPor);
            }
            
            List<DtCategoria> categorias = extraerCategoriasDePropuestas(propuestasVisibles);

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
            
            request.setAttribute("categorias", categorias);
            request.setAttribute("propuestas", propuestasConDatos);
            request.setAttribute("estadoFiltro", estadoFiltro);
            request.setAttribute("busqueda", busqueda);
            request.setAttribute("categoriaFiltro", categoriaFiltro);
            request.setAttribute("ordenarPor", ordenarPor);
            request.setAttribute("esProponente", esProponente);
            request.setAttribute("esColaborador", esColaborador);
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la página principal: " + e.getMessage());
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }
    }

    private boolean coincideConCategoriaFiltro(DtPropuesta propuesta, String filtro) {
        if (filtro == null || propuesta.getCategoria() == null) {
            return false;
        }
        return filtro.equals(propuesta.getCategoria().getNombre());
    }
    
    private List<DtCategoria> extraerCategoriasDePropuestas(List<DtPropuesta> propuestas) {
        List<DtCategoria> categorias = new ArrayList<>();
        java.util.Map<String, DtCategoria> categoriasMap = new java.util.LinkedHashMap<>();

        for (DtPropuesta propuesta : propuestas) {
            try {
                if (propuesta.getCategoria() != null) {
                    DtCategoria categoria = propuesta.getCategoria();
                    String nombreCategoria = categoria.getNombre();
                    if (nombreCategoria != null && !nombreCategoria.isEmpty() && !categoriasMap.containsKey(nombreCategoria)) {
                        categoriasMap.put(nombreCategoria, categoria);
                    }
                }
            } catch (Exception e) {
                System.out.println("Error al obtener categoría de propuesta: " + e.getMessage());
            }
        }

        categorias.addAll(categoriasMap.values());

        if (categorias != null && !categorias.isEmpty()) {
            categorias.sort((c1, c2) -> {
                String nombre1 = c1.getNombre() != null ? c1.getNombre() : "";
                String nombre2 = c2.getNombre() != null ? c2.getNombre() : "";
                return nombre1.compareToIgnoreCase(nombre2);
            });
        }

        return categorias;
    }
    
    private List<DtPropuesta> ordenarPropuestas(List<DtPropuesta> propuestas, String criterioOrdenamiento) {
        List<DtPropuesta> propuestasOrdenadas = new ArrayList<>(propuestas);

        switch (criterioOrdenamiento.toLowerCase()) {
            case "alfabetico":
            case "alfabeticamente":
                propuestasOrdenadas.sort((p1, p2) -> {
                    String titulo1 = p1.getTitulo() != null ? p1.getTitulo() : "";
                    String titulo2 = p2.getTitulo() != null ? p2.getTitulo() : "";
                    return titulo1.compareToIgnoreCase(titulo2);
                });
                break;
            case "fecha_creacion":
            case "fecha_creacion_descendente":
                propuestasOrdenadas.sort((p1, p2) -> {
                    if (p1.getFechaPublicacion() == null && p2.getFechaPublicacion() == null) return 0;
                    if (p1.getFechaPublicacion() == null) return 1;
                    if (p2.getFechaPublicacion() == null) return -1;
                    java.time.LocalDate fecha1 = WSFechaPropuesta.toJavaLocalDate(p1.getFechaPublicacion());
                    java.time.LocalDate fecha2 = WSFechaPropuesta.toJavaLocalDate(p2.getFechaPublicacion());
                    return fecha2.compareTo(fecha1); // Descendente
                });
                break;
            case "monto_ascendente":
                propuestasOrdenadas.sort((p1, p2) -> {
                    double monto1 = p1.getMontoNecesario() != null ? p1.getMontoNecesario() : 0.0;
                    double monto2 = p2.getMontoNecesario() != null ? p2.getMontoNecesario() : 0.0;
                    return Double.compare(monto1, monto2);
                });
                break;
            case "monto_descendente":
                propuestasOrdenadas.sort((p1, p2) -> {
                    double monto1 = p1.getMontoNecesario() != null ? p1.getMontoNecesario() : 0.0;
                    double monto2 = p2.getMontoNecesario() != null ? p2.getMontoNecesario() : 0.0;
                    return Double.compare(monto2, monto1);
                });
                break;
            default:
                break;
        }

        return propuestasOrdenadas;
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
                java.time.LocalDate fechaPublicacion = WSFechaPropuesta.toJavaLocalDate(propuesta.getFechaPublicacion());
                
                if (fechaPublicacion != null) {
                    java.time.LocalDate fechaActual = java.time.LocalDate.now();

                    java.time.LocalDate fechaLimite = fechaPublicacion.plusDays(30);
                    
                    diasRestantes = ChronoUnit.DAYS.between(fechaActual, fechaLimite);
                    if (diasRestantes < 0) {
                        diasRestantes = 0;
                    }
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

    private void verificarVencimientosAutomaticamente() {
        try {
            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();
            
            java.time.LocalDate fechaActual = java.time.LocalDate.now();
            
            for (DtPropuesta dtPropuesta : todasLasPropuestas) {
                DtPropuesta propuesta = IPC.getDTPropuesta(dtPropuesta.getTitulo());
                
                if (propuesta != null && 
                    (propuesta.getEstadoActual() == DtEstadoPropuesta.PUBLICADA ||
                     propuesta.getEstadoActual() == DtEstadoPropuesta.EN_FINANCIACION)) {

                    if (propuesta.getFechaPublicacion() != null) {
                        java.time.LocalDate fechaPublicacion = WSFechaPropuesta.toJavaLocalDate(propuesta.getFechaPublicacion());
                        
                        if (fechaPublicacion != null) {
                            java.time.LocalDate fechaVencimiento = fechaPublicacion.plusDays(30);
                            
                            if (fechaActual.isAfter(fechaVencimiento)) {
                            double montoRecaudado = calcularMontoRecaudado(dtPropuesta);
                            double montoNecesario = dtPropuesta.getMontoNecesario();
                            
                            if (montoRecaudado >= montoNecesario) {
                                propuesta.setEstadoActual(DtEstadoPropuesta.FINANCIADA);

                                DtPropuestaEstado propEstado = new DtPropuestaEstado();
                                propEstado.setPropuesta(propuesta);
                                propEstado.setEstado(DtEstadoPropuesta.FINANCIADA);
                                propEstado.setFechaCambio(WSFechaPropuesta.toWSLocalDateWS(fechaActual));

                                propuesta.getHistorial().add(propEstado);


                                System.out.println("Propuesta '" + propuesta.getTitulo() + 
                                    "' transicionada a FINANCIADA automáticamente (monto recaudado: $" + montoRecaudado + 
                                    ", monto necesario: $" + montoNecesario + ")");
                                
                            } else {
                                propuesta.setEstadoActual(DtEstadoPropuesta.NO_FINANCIADA);

                                DtPropuestaEstado propEstado = new DtPropuestaEstado();
                                propEstado.setPropuesta(propuesta);
                                propEstado.setEstado(DtEstadoPropuesta.NO_FINANCIADA);
                                propEstado.setFechaCambio(WSFechaPropuesta.toWSLocalDateWS(fechaActual));

                                propuesta.getHistorial().add(propEstado);

                                System.out.println("Propuesta '" + propuesta.getTitulo() + 
                                    "' transicionada a NO_FINANCIADA automáticamente (monto recaudado: $" + montoRecaudado + 
                                    ", monto necesario: $" + montoNecesario + ")");
                            }

                            IPC.modificarHistorialYEstadoPropuesta(propuesta);
                            }
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error al verificar vencimientos automáticamente: " + e.getMessage());
            e.printStackTrace();
        }
    }

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


