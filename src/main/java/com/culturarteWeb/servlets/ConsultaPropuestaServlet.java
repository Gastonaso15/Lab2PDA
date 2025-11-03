package com.culturarteWeb.servlets;

import com.culturarteWeb.util.WSFechaUsuario;
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
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

@WebServlet("/consultaPropuesta")
public class ConsultaPropuestaServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
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

            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            List<DtPropuesta> propuestasVisibles = new ArrayList<>();
            
            for (DtPropuesta propuesta : todasLasPropuestas) {
                if (propuesta.getEstadoActual() != DtEstadoPropuesta.INGRESADA) {
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
            List<DtCategoria> categorias = extraerCategoriasReales(propuestasVisibles);
            boolean esProponente = false;
            boolean esColaborador = false;
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("usuarioLogueado") != null) {
                DtUsuario usuarioLogueado = (DtUsuario) session.getAttribute("usuarioLogueado");
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
            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            DtPropuesta propuestaSeleccionada = null;
            
            for (DtPropuesta propuesta : todasLasPropuestas) {
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

            long diasRestantes = 0;
            if (propuestaSeleccionada.getFechaPublicacion() != null) {

                java.time.LocalDate fechaPublicacion = WSFechaPropuesta.toJavaLocalDate(propuestaSeleccionada.getFechaPublicacion());
                java.time.LocalDate fechaActual = java.time.LocalDate.now();

                java.time.LocalDate fechaLimite = fechaPublicacion.plusDays(30);

                diasRestantes = ChronoUnit.DAYS.between(fechaActual, fechaLimite);
                if (diasRestantes < 0) {
                    diasRestantes = 0;
                }
            }
            request.setAttribute("diasRestantes", diasRestantes);

            double montoRecaudado = 0.0;
            List<String> nicknamesColaboradores = new ArrayList<>();
            
            if (propuestaSeleccionada.getColaboraciones() != null) {
                for (DtColaboracion colaboracion : propuestaSeleccionada.getColaboraciones()) {
                    montoRecaudado += colaboracion.getMonto();
                    nicknamesColaboradores.add(colaboracion.getColaborador().getNickname());
                }
            }
            HttpSession sesion = request.getSession(false);
            DtUsuario usuarioActual = null;
            boolean esProponente = false;
            boolean esProponenteDeEstaPropuesta = false;
            boolean haColaborado = false;
            boolean esFavorita = false;
            
            if (sesion != null && sesion.getAttribute("usuarioLogueado") != null) {
                usuarioActual = (DtUsuario) sesion.getAttribute("usuarioLogueado");
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
                if (ICU.usuarioYaTienePropuestaFavorita(usuarioActual.getNickname(), propuestaSeleccionada.getTitulo())){
                    esFavorita = true;
                }
            }

            ListaDTComentario comentariosWS = IPC.obtenerComentariosPropuesta(propuestaSeleccionada.getTitulo());
            List<DtComentario> comentarios = comentariosWS.getComentario();

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
        return false;
    }

    private boolean coincideConEstadoFiltro(String estadoPropuesta, String filtro) {
        if (filtro == null || estadoPropuesta == null) {
            return false;
        }

        estadoPropuesta = estadoPropuesta.toUpperCase();
        switch (filtro.toLowerCase()) {
            case "en_financiacion":
                return estadoPropuesta.equals("EN_FINANCIACION");
            case "financiadas":
                return estadoPropuesta.equals("FINANCIADA");
            case "no_financiadas":
                return estadoPropuesta.equals("NO_FINANCIADA");
            case "canceladas":
                return estadoPropuesta.equals("CANCELADA");
            default:
                return false;
        }
    }


    private boolean coincideConCategoriaFiltro(DtPropuesta propuesta, String filtro) {
        if (filtro == null || propuesta.getCategoria() == null) {
            return false;
        }
        return filtro.equals(propuesta.getCategoria().getNombre());
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
    
    private List<DtCategoria> extraerCategoriasReales(List<DtPropuesta> propuestas) {
        List<DtCategoria> categorias = new ArrayList<>();
        Map<String, DtCategoria> categoriasMap = new LinkedHashMap<>();

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