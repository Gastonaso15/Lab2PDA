package com.culturarteWeb.servlets;
import com.culturarteWeb.util.WSFechaPropuesta;
import culturarte.servicios.cliente.propuestas.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/consultaPropuestaPorCategoria")
public class ConsultaPropuestaPorCategoriaServlet extends HttpServlet {
    private IPropuestaControllerWS IPC;

    @Override
    public void init() throws ServletException {
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            List<DtPropuesta> propuestasVisibles = new ArrayList<>();
            for (DtPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA) {
                    propuestasVisibles.add(propuesta);
                }
            }

            List<DtCategoria> categorias = extraerCategoriasDePropuestas(propuestasVisibles);
            
            List<PrincipalServlet.PropuestaConDatos> propuestasConDatos = new ArrayList<>();
            for (DtPropuesta propuesta : propuestasVisibles) {
                PrincipalServlet.PropuestaConDatos propuestaConDatos = calcularDatosPropuesta(propuesta);
                propuestasConDatos.add(propuestaConDatos);
            }
            
            request.setAttribute("categorias", categorias);
            request.setAttribute("propuestas", propuestasConDatos);

            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar las categorías y propuestas: " + e.getMessage());
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }
    }

    @Override
    protected   void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String[] categoriasSeleccionadas = request.getParameterValues("categoria");
        try{
        ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
        List<DtPropuesta> todasLasPopuestas = propuestasWS.getPropuesta();

        List<DtPropuesta> propuestasVisibles = new ArrayList<>();

        for(DtPropuesta propuesta : todasLasPopuestas){
            if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA){
                propuestasVisibles.add(propuesta);
            }
        }
        
        List<DtPropuesta> propuestasFiltradas = new ArrayList<>();

        if(categoriasSeleccionadas != null && categoriasSeleccionadas.length > 0){
            for(DtPropuesta propuesta : propuestasVisibles){
                boolean perteneceACategoria = false;

                try{
                    if(propuesta.getCategoria() != null){
                        String categoriaPropuesta = propuesta.getCategoria().getNombre();
                        for(String categoriasSeleccionada : categoriasSeleccionadas){
                            if(categoriaPropuesta.equals(categoriasSeleccionada)){
                                perteneceACategoria = true;
                                break;
                            }
                        }
                    }
                } catch(Exception e) {
                    System.out.println("Error al verificar categoría de propuesta: " + e.getMessage());
                }
                if(perteneceACategoria){
                    propuestasFiltradas.add(propuesta);
                }
            }
        }else {
            propuestasFiltradas = propuestasVisibles;
        }
        
       List<DtCategoria> todasLasCategorias = extraerCategoriasDePropuestas(propuestasVisibles);
        
       List<PrincipalServlet.PropuestaConDatos> propuestasConDatos = new ArrayList<>();
        for (DtPropuesta propuesta : propuestasFiltradas) {
            PrincipalServlet.PropuestaConDatos propuestaConDatos = calcularDatosPropuesta(propuesta);
            propuestasConDatos.add(propuestaConDatos);
        }
        
        request.setAttribute("categorias", todasLasCategorias);
        request.setAttribute("propuestas", propuestasConDatos);
        request.setAttribute("categoriasSeleccionadas", categoriasSeleccionadas);
        request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }catch (Exception e) {
            request.setAttribute("error", "Error al filtrar las propuestas por categoría: " + e.getMessage());
            request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }
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
    
    private PrincipalServlet.PropuestaConDatos calcularDatosPropuesta(DtPropuesta propuesta) {
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
        
        return new PrincipalServlet.PropuestaConDatos(propuesta, montoRecaudado, totalColaboradores, diasRestantes);
    }
}
