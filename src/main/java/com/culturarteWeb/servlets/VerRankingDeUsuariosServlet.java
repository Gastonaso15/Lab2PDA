package com.culturarteWeb.servlets;


import culturarte.servicios.cliente.propuestas.IPropuestaControllerWS;
import culturarte.servicios.cliente.propuestas.PropuestaWSEndpointService;
import culturarte.servicios.cliente.usuario.DtUsuario;
import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.ListaStrings;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;

@WebServlet("/VerRankingDeUsuarios")
public class VerRankingDeUsuariosServlet extends HttpServlet {

    private IPropuestaControllerWS IPC;
    private IUsuarioControllerWS ICU;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            PropuestaWSEndpointService propuestaServicio = new PropuestaWSEndpointService();
            IPC = propuestaServicio.getPropuestaWSEndpointPort();

            UsuarioWSEndpointService usuarioServicio = new UsuarioWSEndpointService();
            ICU = usuarioServicio.getUsuarioWSEndpointPort();

        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    //Obtengo los Nicknames de los usuarios para poder ordenarlos por cantidad de followers, para ello deben tener como mínimo 1 follower
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String nick = req.getParameter("nick");
        //Muestro la lista de usuarios disponibles a consultar
        if (nick == null || nick.isBlank()) {
            try {
                ListaStrings nicksWS = ICU.devolverNicknamesUsuarios();
                List<String> nicks = nicksWS.getItem();

                List<Map<String, Object>> usuariosCombo = new ArrayList<>();

                for (String n : nicks) {
                    DtUsuario u = ICU.getDTUsuario(n);
                    if (u == null) continue;

                    String tipo;
                    try {
                        ICU.devolverProponentePorNickname(n);
                        tipo = "Proponente";
                    } catch (Exception ex) {
                        tipo = "Colaborador";
                    }
                    ListaStrings nicks2WS = ICU.devolverUsuariosSeguidores(n);
                    if (nicks2WS == null) continue; //voy al siguiente usuario (n)
                    List<String> followers = nicks2WS.getItem();
                    Integer cantFollowers = followers.size();



                    Map<String, Object> row = new HashMap<>();
                    row.put("id", u.getId());
                    row.put("cantFollowers", cantFollowers);
                    row.put("nick", u.getNickname());
                    row.put("nombre", u.getNombre());
                    row.put ("imagen", u.getImagen());
                    row.put("apellido", u.getApellido());
                    row.put("tipo", tipo);
                    usuariosCombo.add(row);
                }

                usuariosCombo.sort((a, b) -> {
                    int fb = ((Number) b.getOrDefault("cantFollowers", 0)).intValue();
                    int fa = ((Number) a.getOrDefault("cantFollowers", 0)).intValue();
                    int cmp = Integer.compare(fb, fa);
                    if (cmp != 0) return cmp;
                    //desempato por nick
                    String nb = String.valueOf(b.getOrDefault("nick", ""));
                    String na = String.valueOf(a.getOrDefault("nick", ""));
                    return na.compareToIgnoreCase(nb);
                });
                // Una ves ordenado creo un nuevo atributo para que se vea lindo el ranking
                int rank = 1;
                for (Map<String, Object> row : usuariosCombo) {
                    row.put("rank", rank++);
                }
                // Seteo la lista  para el JSP
                req.setAttribute("usuariosCombo", usuariosCombo);

            } catch (Exception e) {
                req.setAttribute("error", "No se pudo listar usuarios: " + e.getMessage());
            }

            boolean esProponente = false;
            boolean esColaborador = false;
            HttpSession session = req.getSession(false);
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
            req.setAttribute("esProponente", esProponente);
            req.setAttribute("esColaborador", esColaborador);

            //envio los datos ya cargados al jsp con el Dispatcher
            req.getRequestDispatcher("/verRankingDeUsuarios.jsp").forward(req, resp);
        }
    }
}