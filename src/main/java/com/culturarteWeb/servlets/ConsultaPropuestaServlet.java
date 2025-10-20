package com.culturarteWeb.servlets;

import culturarte.logica.DTs.DTPropuesta;
import culturarte.logica.DTs.DTUsuario;
import culturarte.logica.DTs.DTColaboracion;
import culturarte.logica.DTs.DTEstadoPropuesta;
import culturarte.logica.DTs.DTComentario;
import culturarte.logica.DTs.DTCategoria;
import culturarte.logica.Fabrica;
import culturarte.logica.controladores.IPropuestaController;

import culturarte.logica.controladores.IUsuarioController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

@WebServlet("/consultaPropuesta")
public class ConsultaPropuestaServlet extends HttpServlet {

    private IPropuestaController IPC;
    private IUsuarioController ICU;

    @Override
    public void init() throws ServletException {
        Fabrica fabrica = Fabrica.getInstance();
        IPC = fabrica.getIPropuestaController();
        ICU = fabrica.getIUsuarioController();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        if ("detalle".equals(accion)) {
            mostrarDetallePropuesta(request, response);
        } else {
            mostrarListaPropuestas(request, response);
        }
    }
    
    private void mostrarListaPropuestas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String busqueda = request.getParameter("busqueda");
            String estadoFiltro = request.getParameter("estado");
            String categoriaFiltro = request.getParameter("categoria");
            String ordenarPor = request.getParameter("ordenarPor");
            
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            List<DTPropuesta> propuestasVisibles = new ArrayList<>();
            
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DTEstadoPropuesta.INGRESADA) {
                    boolean cumpleBusqueda = true;
                    boolean cumpleEstado = true;
                    boolean cumpleCategoria = true;

                    if (busqueda != null && !busqueda.trim().isEmpty()) {
                        cumpleBusqueda = coincideConBusqueda(propuesta, busqueda.trim());
                    }
                    if (estadoFiltro != null && !estadoFiltro.isEmpty() && !"todas".equals(estadoFiltro)) {
                        cumpleEstado = coincideConEstadoFiltro(propuesta.getEstadoActual().toString(), estadoFiltro);
                    }
                    if (categoriaFiltro != null && !categoriaFiltro.isEmpty() && !"todas".equals(categoriaFiltro)) {
                        cumpleCategoria = coincideConCategoriaFiltro(propuesta, categoriaFiltro);
                    }
                    if (cumpleBusqueda && cumpleEstado && cumpleCategoria) {
                        propuestasVisibles.add(propuesta);
                    }
                }
            }

            if (ordenarPor != null && !ordenarPor.isEmpty()) {
                propuestasVisibles = ordenarPropuestas(propuestasVisibles, ordenarPor);
            }
            List<DTCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
            boolean esProponente = false;
            boolean esColaborador = false;
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("usuarioLogueado") != null) {
                DTUsuario usuarioLogueado = (DTUsuario) session.getAttribute("usuarioLogueado");
                try {
                    ICU.devolverProponentePorNickname(usuarioLogueado.getNickname());
                    esProponente = true;
                } catch (Exception e) {
                    esProponente = false;
                }
                
                try {
                    ICU.devolverColaboradorPorNickname(usuarioLogueado.getNickname());
                    esColaborador = true;
                } catch (Exception e) {
                    esColaborador = false;
                }
            }
            
            request.setAttribute("propuestas", propuestasVisibles);
            request.setAttribute("categorias", categorias);
            request.setAttribute("busqueda", busqueda);
            request.setAttribute("estadoFiltro", estadoFiltro);
            request.setAttribute("categoriaFiltro", categoriaFiltro);
            request.setAttribute("ordenarPor", ordenarPor);
            request.setAttribute("esProponente", esProponente);
            request.setAttribute("esColaborador", esColaborador);
            request.setAttribute("totalResultados", propuestasVisibles.size());
            
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar las propuestas: " + e.getMessage());
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
        }
    }
    
    private void mostrarDetallePropuesta(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tituloPropuesta = request.getParameter("titulo");
        
        if (tituloPropuesta == null || tituloPropuesta.trim().isEmpty()) {
            request.setAttribute("error", "Título de propuesta no especificado");
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
            return;
        }
        
        try {
            List<DTPropuesta> todasLasPropuestas = IPC.devolverTodasLasPropuestas();
            DTPropuesta propuestaSeleccionada = null;
            
            for (DTPropuesta propuesta : todasLasPropuestas) {
                if (tituloPropuesta.equals(propuesta.getTitulo())) {
                    propuestaSeleccionada = propuesta;
                    break;
                }
            }
            
            if (propuestaSeleccionada == null) {
                request.setAttribute("error", "Propuesta no encontrada");
                request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
                return;
            }
            double montoRecaudado = 0.0;
            List<String> nicknamesColaboradores = new ArrayList<>();
            
            if (propuestaSeleccionada.getColaboraciones() != null) {
                for (DTColaboracion colaboracion : propuestaSeleccionada.getColaboraciones()) {
                    montoRecaudado += colaboracion.getMonto();
                    nicknamesColaboradores.add(colaboracion.getColaborador().getNickname());
                }
            }
            HttpSession sesion = request.getSession(false);
            DTUsuario usuarioActual = null;
            boolean esProponente = false;
            boolean esProponenteDeEstaPropuesta = false;
            boolean haColaborado = false;
            boolean esFavorita = false;
            
            if (sesion != null && sesion.getAttribute("usuarioLogueado") != null) {
                usuarioActual = (DTUsuario) sesion.getAttribute("usuarioLogueado");
                if (propuestaSeleccionada.getDTProponente() != null && 
                    usuarioActual.getNickname().equals(propuestaSeleccionada.getDTProponente().getNickname())) {
                    esProponenteDeEstaPropuesta = true;
                }

                try {
                    ICU.devolverProponentePorNickname(usuarioActual.getNickname());
                    esProponente = true;
                } catch (Exception e) {
                    esProponente = false;
                }
                
                if (nicknamesColaboradores.contains(usuarioActual.getNickname())) {
                    haColaborado = true;
                }
                if (ICU.UsuarioYaTienePropuestaFavorita(usuarioActual.getNickname(), propuestaSeleccionada.getTitulo())){
                    esFavorita = true;
                }
            }

            List<DTComentario> comentarios = IPC.obtenerComentariosPropuesta(propuestaSeleccionada.getTitulo());
            request.setAttribute("propuesta", propuestaSeleccionada);
            request.setAttribute("montoRecaudado", montoRecaudado);
            request.setAttribute("nicknamesColaboradores", nicknamesColaboradores);
            request.setAttribute("esProponente", esProponente);
            request.setAttribute("esProponenteDeEstaPropuesta", esProponenteDeEstaPropuesta);
            request.setAttribute("haColaborado", haColaborado);
            request.setAttribute("usuarioActual", usuarioActual);
            request.setAttribute("esFavorita", esFavorita);
            request.setAttribute("comentarios", comentarios);
            
            request.getRequestDispatcher("/detallePropuesta.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la propuesta: " + e.getMessage());
            request.getRequestDispatcher("/listaPropuestas.jsp").forward(request, response);
        }
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
    
    private boolean coincideConCategoriaFiltro(DTPropuesta propuesta, String filtro) {
        if (filtro == null || propuesta.getCategoria() == null) {
            return false;
        }
        return filtro.equals(propuesta.getCategoria().getNombre());
    }
    
    private List<DTPropuesta> ordenarPropuestas(List<DTPropuesta> propuestas, String criterioOrdenamiento) {
        List<DTPropuesta> propuestasOrdenadas = new ArrayList<>(propuestas);

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
                    return p2.getFechaPublicacion().compareTo(p1.getFechaPublicacion()); // Descendente
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
    
    private List<DTCategoria> extraerCategoriasReales(List<DTPropuesta> propuestas) {
        List<DTCategoria> categorias = new ArrayList<>();
        Map<String, DTCategoria> categoriasMap = new LinkedHashMap<>();

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