package com.culturarteWeb.servlets;
import culturarte.servicios.cliente.propuestas.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
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
            List<DtPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> propuestasVisibles = new ArrayList<>();
            for (DtPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA) {
                    propuestasVisibles.add(propuesta);
                }
            }
            List<DtCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
            request.setAttribute("categorias", categorias);
            request.setAttribute("propuestas", propuestasVisibles);

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
        List<DtPropuesta> todasLasPopuestas = IPC.devolverTodasLasPropuestas();
        List<DtPropuesta> propuestasVisibles = new ArrayList<>();

        for(DtPropuesta propuesta : todasLasPopuestas){
            if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA){
                propuestasVisibles.add(propuesta);
            }
        }
        List<DtCategoria> todasLasCategorias = extraerCategoriasReales(propuestasVisibles);
        request.setAttribute("categorias", todasLasCategorias);
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
        request.setAttribute("propuestas", propuestasFiltradas);
        request.setAttribute("categoriasSeleccionadas", categoriasSeleccionadas);
        request.getRequestDispatcher("/principal.jsp").forward(request, response);
        }catch (Exception e) {
            request.setAttribute("error", "Error al filtrar las propuestas por categoría: " + e.getMessage());
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
}
