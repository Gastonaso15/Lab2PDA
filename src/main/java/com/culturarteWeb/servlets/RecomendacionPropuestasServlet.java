package com.culturarteWeb.servlets;

import culturarte.servicios.cliente.propuestas.*;
import culturarte.servicios.cliente.usuario.DtColaboracion;
import culturarte.servicios.cliente.propuestas.DtEstadoPropuesta;
import culturarte.servicios.cliente.propuestas.DtPropuesta;
import culturarte.servicios.cliente.usuario.*;
import culturarte.servicios.cliente.usuario.DtColaborador;
import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.ListaStrings;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.lang.Exception;
import java.util.*;

@WebServlet("/recomendacionPropuestas")
public class RecomendacionPropuestasServlet extends HttpServlet {

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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect(request.getContextPath() + "/inicioDeSesion.jsp");
            return;
        }

        DtUsuario usuarioActual = (DtUsuario) session.getAttribute("usuarioLogueado");
        String nickname = usuarioActual.getNickname();

        try {
            DtColaborador colaborador;
            try {
                colaborador = ICU.devolverColaboradorPorNickname(nickname);
            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/recomendacionPropuestas.jsp").forward(request, response);
                return;
            }

            ListaDTPropuesta propuestasWS = IPC.devolverTodasLasPropuestas();
            List<DtPropuesta> todasLasPropuestas = propuestasWS.getPropuesta();

            List<String> propuestasColaboradas = new ArrayList<>();
            if (colaborador.getColaboraciones() != null) {
                for (DtColaboracion colaboracion : colaborador.getColaboraciones()) {
                    if (colaboracion.getPropuesta() != null) {
                        String titulo = colaboracion.getPropuesta().getTitulo();
                        if (!propuestasColaboradas.contains(titulo)) {
                            propuestasColaboradas.add(titulo);
                        }
                    }
                }
            }

            ListaStrings usuariosSeguidosWS = ICU.devolverUsuariosSeguidos(nickname);
            List<String> usuariosSeguidos = usuariosSeguidosWS.getItem();

            List<String> usuariosSimilares = new ArrayList<>();
            if (colaborador.getColaboraciones() != null) {
                for (DtColaboracion colaboracion : colaborador.getColaboraciones()) {
                    if (colaboracion.getPropuesta() != null) {
                        culturarte.servicios.cliente.usuario.DtPropuesta propuesta = colaboracion.getPropuesta();
                        if (propuesta.getColaboraciones() != null) {
                            for (DtColaboracion otraColaboracion : propuesta.getColaboraciones()) {
                                if (otraColaboracion.getColaborador() != null) {
                                    String otroColaborador = otraColaboracion.getColaborador().getNickname();
                                    if (!otroColaborador.equals(nickname) && !usuariosSimilares.contains(otroColaborador)) {
                                        usuariosSimilares.add(otroColaborador);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            List<String> propuestasCandidatas = new ArrayList<>();

            for (String usuarioSeguido : usuariosSeguidos) {
                try {
                    DtColaborador colaboradorSeguido = ICU.devolverColaboradorPorNickname(usuarioSeguido);
                    if (colaboradorSeguido.getColaboraciones() != null) {
                        for (DtColaboracion colaboracion : colaboradorSeguido.getColaboraciones()) {
                            if (colaboracion.getPropuesta() != null) {
                                String titulo = colaboracion.getPropuesta().getTitulo();
                                if (!propuestasColaboradas.contains(titulo) && !propuestasCandidatas.contains(titulo)) {
                                    propuestasCandidatas.add(titulo);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.out.print(usuarioSeguido + "no es colaborador");
                }
            }

            for (String usuarioSimilar : usuariosSimilares) {
                try {
                    DtColaborador colaboradorSimilar = ICU.devolverColaboradorPorNickname(usuarioSimilar);
                    if (colaboradorSimilar.getColaboraciones() != null) {
                        for (DtColaboracion colaboracion : colaboradorSimilar.getColaboraciones()) {
                            if (colaboracion.getPropuesta() != null) {
                                String titulo = colaboracion.getPropuesta().getTitulo();
                                if (!propuestasColaboradas.contains(titulo) && !propuestasCandidatas.contains(titulo)) {
                                    propuestasCandidatas.add(titulo);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.out.print(usuarioSimilar + "no es colaborador");
                }
            }

            Map<String, DtPropuesta> propuestasValidasMap = new HashMap<>();
            for (String titulo : propuestasCandidatas) {
                for (DtPropuesta p : todasLasPropuestas) {
                    if (p.getTitulo() != null && p.getTitulo().equals(titulo) && p.getEstadoActual() != DtEstadoPropuesta.INGRESADA) {
                        propuestasValidasMap.put(p.getTitulo(), p);
                        break;
                    }
                }
            }
            List<DtPropuesta> propuestasValidas = new ArrayList<>(propuestasValidasMap.values());


            ListaStrings todosLosUsuariosWS = ICU.devolverNicknamesUsuarios();
            List<String> todosLosUsuarios = todosLosUsuariosWS.getItem();

            Map<String, Map<String, Object>> puntajesPorPropuesta = new HashMap<>();

            for (DtPropuesta propuesta : propuestasValidas) {
                Map<String, Object> detallesPuntuacion = new HashMap<>();

                int cantidadColaboradores = 0;
                if (propuesta.getColaboraciones() != null) {
                    cantidadColaboradores = propuesta.getColaboraciones().size();
                }

                double montoRecaudado = 0.0;
                if (propuesta.getColaboraciones() != null) {
                    for (culturarte.servicios.cliente.propuestas.DtColaboracion colaboracion : propuesta.getColaboraciones()) {
                        montoRecaudado += colaboracion.getMonto();
                    }
                }

                double montoNecesario = propuesta.getMontoNecesario() != null ? propuesta.getMontoNecesario() : 1.0;
                double porcentajeFinanciacion = (montoRecaudado / montoNecesario) * 100.0;
                int puntajeFinanciacion = calcularPuntajeFinanciacion(porcentajeFinanciacion);

                int cantidadFavoritos = 0;
                for (String usuario : todosLosUsuarios) {
                    try {
                        if (ICU.usuarioYaTienePropuestaFavorita(usuario, propuesta.getTitulo())) {
                            cantidadFavoritos++;
                        }
                    } catch (Exception e) {
                        System.out.print("Error al consultar los favoritos de " + usuario);
                    }
                }

                int puntajeTotal = cantidadColaboradores + puntajeFinanciacion + cantidadFavoritos;

                detallesPuntuacion.put("puntajeTotal", puntajeTotal);
                detallesPuntuacion.put("cantidadColaboradores", cantidadColaboradores);
                detallesPuntuacion.put("puntajeFinanciacion", puntajeFinanciacion);
                detallesPuntuacion.put("cantidadFavoritos", cantidadFavoritos);
                detallesPuntuacion.put("montoRecaudado", montoRecaudado);
                detallesPuntuacion.put("porcentajeFinanciacion", porcentajeFinanciacion);

                puntajesPorPropuesta.put(propuesta.getTitulo(), detallesPuntuacion);
            }

            propuestasValidas.sort((p1, p2) -> {
                int puntaje1 = (int) puntajesPorPropuesta.getOrDefault(p1.getTitulo(),
                        new HashMap<>()).getOrDefault("puntajeTotal", 0);
                int puntaje2 = (int) puntajesPorPropuesta.getOrDefault(p2.getTitulo(),
                        new HashMap<>()).getOrDefault("puntajeTotal", 0);
                return Integer.compare(puntaje2, puntaje1);});

            List<DtPropuesta> top10Propuestas = propuestasValidas.size() > 10 ? propuestasValidas.subList(0, 10) :
                    propuestasValidas;

            boolean esProponente = false;
            boolean esColaborador = true;

            try {
                ICU.devolverProponentePorNickname(nickname);
                esProponente = true;
            } catch (Exception e) {
                System.out.print(nickname + " no es proponente");
            }

            request.setAttribute("propuestasRecomendadas", top10Propuestas);
            request.setAttribute("puntajesPorPropuesta", puntajesPorPropuesta);
            request.setAttribute("usuarioActual", usuarioActual);
            request.setAttribute("esProponente", esProponente);
            request.setAttribute("esColaborador", esColaborador);
            request.setAttribute("totalCandidatas", propuestasCandidatas.size());

            request.getRequestDispatcher("/recomendacionPropuestas.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/recomendacionPropuestas.jsp").forward(request, response);
        }
    }

    private int calcularPuntajeFinanciacion(double porcentajeFinanciacion) {
        if (porcentajeFinanciacion <= 25.0) return 1;
        else if (porcentajeFinanciacion <= 50.0) return 2;
        else if (porcentajeFinanciacion <= 75.0) return 3;
        else return 4;
    }
}