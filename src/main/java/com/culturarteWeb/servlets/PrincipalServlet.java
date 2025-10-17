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
            String busqueda = request.getParameter("busqueda");
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasVisibles = new ArrayList<>();

            // Filtrar propuestas según el estado seleccionado
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA) {
                    boolean cumpleEstado = false;
                    
                    // Filtrar por estado
                    if (estadoFiltro == null || estadoFiltro.isEmpty() || "todas".equals(estadoFiltro)) {
                        cumpleEstado = true; // Mostrar todas las propuestas visibles
                    } else {
                        cumpleEstado = coincideConEstadoFiltro(propuesta.getEstadoActual().toString(), estadoFiltro);
                    }
                    
                    // Filtrar por búsqueda si se proporciona
                    boolean cumpleBusqueda = true;
                    if (busqueda != null && !busqueda.trim().isEmpty()) {
                        cumpleBusqueda = coincideConBusqueda(propuesta, busqueda.trim());
                    }
                    
                    // Agregar si cumple ambos filtros
                    if (cumpleEstado && cumpleBusqueda) {
                        propuestasVisibles.add(propuesta);
                    }
                }
            }

            List<DTCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
            request.setAttribute("categorias", categorias);
            request.setAttribute("propuestas", propuestasVisibles);
            request.setAttribute("estadoFiltro", estadoFiltro);
            request.setAttribute("busqueda", busqueda);
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
        
        // Buscar en título
        if (propuesta.getTitulo() != null && 
            propuesta.getTitulo().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        
        // Buscar en descripción
        if (propuesta.getDescripcion() != null && 
            propuesta.getDescripcion().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        
        // Buscar en lugar
        if (propuesta.getLugar() != null && 
            propuesta.getLugar().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        
        // Buscar en nombre del proponente
        if (propuesta.getDTProponente() != null && 
            propuesta.getDTProponente().getNickname() != null &&
            propuesta.getDTProponente().getNickname().toLowerCase().contains(busquedaLower)) {
            return true;
        }
        
        // Buscar en categoría
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

}


