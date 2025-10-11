package com.culturarteWeb.servlets;
import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTCategoria;
import culturarte.logica.DTs.DTEstadoPropuesta;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/consultaPropuestaPorCategoria")
public class ConsultaPropuestaPorCategoriaServlet extends HttpServlet {
    private IPropuestaController IPC;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasVisibles = new ArrayList<>();
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA) {
                    propuestasVisibles.add(propuesta);
                }
            }
            List<DTCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
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
        List<DTPropuesta> todasLasPopuestas = IPC.devolverTodasLasPropuestas();
        List<DTPropuesta> propuestasVisibles = new ArrayList<>();

        for(DTPropuesta propuesta : todasLasPopuestas){
            if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA){
                propuestasVisibles.add(propuesta);
            }
        }
        List<DTCategoria> todasLasCategorias = extraerCategoriasReales(propuestasVisibles);
        request.setAttribute("categorias", todasLasCategorias);
        List<DTPropuesta> propuestasFiltradas = new ArrayList<>();

        if(categoriasSeleccionadas != null && categoriasSeleccionadas.length > 0){
            for(DTPropuesta propuesta : propuestasVisibles){
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
}
