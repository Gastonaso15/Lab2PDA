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

@WebServlet("/principal")
public class PrincipalServlet extends HttpServlet {
    private IPropuestaController IPC;

    @Override
    public void init() throws  ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try{
            String estadoFiltro = request.getParameter("estado");
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasVisibles = new ArrayList<>();
            
            // Filtrar propuestas según el estado seleccionado
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA) {
                    if (estadoFiltro == null || estadoFiltro.isEmpty() || "todas".equals(estadoFiltro)) {
                        // Mostrar todas las propuestas visibles (estado "Propuestas Creadas")
                        propuestasVisibles.add(propuesta);
                    } else {
                        // Filtrar por estado específico
                        if (coincideConEstadoFiltro(propuesta.getEstadoActual().toString(), estadoFiltro)) {
                            propuestasVisibles.add(propuesta);
                        }
                    }
                }
            }
            
            List<DTCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
            request.setAttribute("categorias", categorias);
            request.setAttribute("propuestas", propuestasVisibles);
            request.setAttribute("estadoFiltro", estadoFiltro);
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

}

