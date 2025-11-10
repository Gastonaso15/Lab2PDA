<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.servicios.cliente.propuestas.DtPropuesta, culturarte.servicios.cliente.usuario.DtUsuario, culturarte.servicios.cliente.propuestas.DtComentario, java.util.List, java.time.format.DateTimeFormatter, com.culturarteWeb.util.WSFechaPropuesta" %>
<!DOCTYPE html>
<html>
<head>
    <title>Detalle de Propuesta - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">

<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
    
    <div class="py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header">
                    <h3 class="text-center mb-0">Detalle de Propuesta</h3>
                </div>
                <div class="card-body">

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger" role="alert">
                            <%= request.getAttribute("error") %>
                        </div>
                    <% } else {
                        DtPropuesta propuesta = (DtPropuesta) request.getAttribute("propuesta");
                        Double montoRecaudado = (Double) request.getAttribute("montoRecaudado");
                        List<String> nicknamesColaboradores = (List<String>) request.getAttribute("nicknamesColaboradores");
                        Boolean esProponente = (Boolean) request.getAttribute("esProponente");
                        Boolean haColaborado = (Boolean) request.getAttribute("haColaborado");
                        DtUsuario usuarioActual = (DtUsuario) request.getAttribute("usuarioActual");
                        Boolean esFavorita = (Boolean) request.getAttribute("esFavorita");
                        List<DtComentario> comentarios = (List<DtComentario>) request.getAttribute("comentarios");
                    %>

                        <%
                        String imagenPropuesta = propuesta.getImagen();
                        boolean tieneImagen = imagenPropuesta != null && !imagenPropuesta.trim().isEmpty();
                        %>

                        <% if (tieneImagen) { %>
                            <div class="text-center mb-4">
                                <img src="<%= request.getContextPath() %>/<%= imagenPropuesta %>"
                                     class="img-fluid rounded" style="max-height: 300px;"
                                     alt="Imagen de <%= propuesta.getTitulo() %>"
                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            </div>
                        <% } else { %>
                            <img src="<%= request.getContextPath() %>/imagenes/propuestaDefault.png"
                                class="card-img-top" style="height: 200px; object-fit: cover;"
                                alt="Imagen por defecto">
                        <% } %>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h4><%= propuesta.getTitulo() %></h4>
                                <p class="text-muted"><%= propuesta.getDescripcion() %></p>
                            </div>
                            <div class="col-md-6">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h6 class="card-title">Estado</h6>
                                        <span class="badge bg-primary fs-6"><%= propuesta.getEstadoActual() %></span>

                                        <h6 class="card-title mt-3">Monto Necesario</h6>
                                        <p class="mb-0">$<%= String.format("%.2f", propuesta.getMontoNecesario()) %></p>

                                        <h6 class="card-title mt-3">Monto Recaudado</h6>
                                        <p class="mb-0">$<%= String.format("%.2f", montoRecaudado) %></p>

                                        <div class="progress mt-2">
                                            <div class="progress-bar" role="progressbar"
                                                 style="width: <%= (montoRecaudado / propuesta.getMontoNecesario()) * 100 %>%">
                                                <%= String.format("%.1f", (montoRecaudado / propuesta.getMontoNecesario()) * 100) %>%
                                            </div>
                                        </div>

                                        <%
                                            Long diasRestantes = (Long) request.getAttribute("diasRestantes");
                                            if (diasRestantes != null) {
                                        %>

                                        <h6 class="card-title mt-3">⏰ <%= diasRestantes %> días restantes</h6>

                                        <% } %>

                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="mb-4">
                            <dl class="row">
                                <dt class="col-sm-3"><i class="bi bi-person-fill text-muted"></i> Proponente</dt>
                                <dd class="col-sm-9"><%= propuesta.getDTProponente() != null ?
                                    propuesta.getDTProponente().getNickname() : "N/A" %></dd>

                                <dt class="col-sm-3"><i class="bi bi-bookmark-fill text-muted"></i> Categoría</dt>
                                <dd class="col-sm-9"><%= propuesta.getCategoria() != null ?
                                    propuesta.getCategoria().getNombre() : "Sin categoría" %></dd>

                                <dt class="col-sm-3"><i class="bi bi-geo-alt-fill text-muted"></i> Lugar</dt>
                                <dd class="col-sm-9"><%= propuesta.getLugar() != null ? propuesta.getLugar() : "No especificado" %></dd>

                                <dt class="col-sm-3"><i class="bi bi-calendar-event text-muted"></i> Fecha Prevista</dt>
                                <dd class="col-sm-9"><%
                                    if (propuesta.getFechaPrevista() != null) {
                                        java.time.LocalDate fechaPrevista = WSFechaPropuesta.toJavaLocalDate(propuesta.getFechaPrevista());
                                        out.print(fechaPrevista != null ? fechaPrevista.toString() : "No especificada");
                                    } else {
                                        out.print("No especificada");
                                    }
                                %></dd>

                                <dt class="col-sm-3"><i class="bi bi-calendar-check text-muted"></i> Publicación</dt>
                                <dd class="col-sm-9"><%
                                    if (propuesta.getFechaPublicacion() != null) {
                                        java.time.LocalDate fechaPublicacion = WSFechaPropuesta.toJavaLocalDate(propuesta.getFechaPublicacion());
                                        out.print(fechaPublicacion != null ? fechaPublicacion.toString() : "No publicada");
                                    } else {
                                        out.print("No publicada");
                                    }
                                %></dd>

                                <% if (propuesta.getPrecioEntrada() != null && propuesta.getPrecioEntrada() > 0) { %>
                                    <dt class="col-sm-3"><i class="bi bi-ticket-fill text-muted"></i> Precio Entrada</dt>
                                    <dd class="col-sm-9">$<%= String.format("%.2f", propuesta.getPrecioEntrada()) %></dd>
                                <% } %>
                            </dl>
                        </div>

                        <div class="mb-4">
                            <h6>Colaboradores (<%= nicknamesColaboradores.size() %>)</h6>
                            <% if (!nicknamesColaboradores.isEmpty()) { %>
                                <div class="d-flex flex-wrap gap-2">
                                    <% for (String nickname : nicknamesColaboradores) { %>
                                        <span class="badge bg-success"><%= nickname %></span>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <p class="text-muted">Aún no hay colaboradores</p>
                            <% } %>
                        </div>

                        <div class="mb-4">
                            <h6>Comentarios de Colaboradores (<%= comentarios != null ? comentarios.size() : 0 %>)</h6>

                            <% if (comentarios != null && !comentarios.isEmpty()) { %>
                                <div class="row">
                                    <% for (DtComentario comentario : comentarios) { %>
                                        <div class="col-12 mb-3">
                                            <div class="card border-start border-info border-4">
                                                <div class="card-body">
                                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                                        <div>
                                                            <h6 class="card-title mb-1">
                                                                <i class="bi bi-person-circle text-info"></i>
                                                                <% 
                                                                    String nickname = "Usuario Anónimo";
                                                                    if (comentario.getUsuario() != null && comentario.getUsuario().getNickname() != null) {
                                                                        nickname = comentario.getUsuario().getNickname();
                                                                    }
                                                                    System.out.print(nickname);
                                                                %>
                                                            </h6>
                                                            <% if (comentario.getUsuario() != null && comentario.getUsuario().getNombre() != null) { %>
                                                                <small class="text-muted">
                                                                    <%= comentario.getUsuario().getNombre() %> 
                                                                    <%= comentario.getUsuario().getApellido() != null ? comentario.getUsuario().getApellido() : "" %>
                                                                </small>
                                                            <% } %>
                                                        </div>
                                                        <small class="text-muted">
                                                            <% 
                                                                if (comentario.getFechaHora() != null) {
                                                                    java.time.LocalDateTime fechaHora = WSFechaPropuesta.toJavaLocalDateTime(comentario.getFechaHora());
                                                                    if (fechaHora != null) {
                                                                        System.out.print(fechaHora.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
                                                                    } else {
                                                                        System.out.print("Fecha no disponible");
                                                                    }
                                                                } else {
                                                                    System.out.print("Fecha no disponible");
                                                                }
                                                            %>
                                                        </small>
                                                    </div>
                                                    <p class="card-text">
                                                        <%= comentario.getContenido() != null ? comentario.getContenido() : "Sin contenido" %>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="text-center py-4">
                                    <div class="text-muted">
                                        <i class="bi bi-chat-dots" style="font-size: 2rem;"></i>
                                        <p class="mt-2 mb-0">Aún no hay comentarios</p>
                                        <small>Los colaboradores pueden compartir su experiencia aquí</small>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <div class="border-top pt-4">
                            <h6>Acciones Disponibles</h6>

                            <% if (usuarioActual != null) { %>
                                <% if (esProponente && propuesta.getDTProponente() != null && usuarioActual.getNickname().equals(propuesta.getDTProponente().getNickname())) { %>
                                    <div class="d-flex gap-2 mb-3">

                                            <%
                                                String _tituloSel = null;
                                                DtPropuesta _prop = (DtPropuesta) request.getAttribute("propuesta");
                                                if (_prop != null) _tituloSel = _prop.getTitulo();
                                                if (_tituloSel == null) _tituloSel = request.getParameter("titulo");
                                                String _tituloEnc = (_tituloSel != null)
                                                        ? java.net.URLEncoder.encode(_tituloSel, "UTF-8")
                                                        : "";
                                            %>

                                            <%
                                                String tituloParaJS = (_tituloSel != null) ? _tituloSel.replace("'", "\\'") : "";
                                            %>

                                        <div id="extender-msg" style="margin:8px 0;"></div>

                                        <button type="button" class="btn btn-warning"
                                                onclick="extenderFinanciacion('<%= tituloParaJS %>')">
                                            Extender Financiación
                                        </button>

                                        <%
                                            boolean puedeExtender = propuesta.getEstadoActual() != null &&
                                                (propuesta.getEstadoActual().toString().equals("PUBLICADA") ||
                                                 propuesta.getEstadoActual().toString().equals("EN_FINANCIACION"));
                                        if (!puedeExtender) { %>
                                            <script>
                                                document.addEventListener('DOMContentLoaded', () => {
                                                    const btn = document.querySelector('.btn.btn-warning');
                                                    if (btn) btn.disabled = true;
                                                });
                                            </script>
                                        <% } %>

                                        <script>
                                            async function extenderFinanciacion(titulo) {
                                                if (!confirm('¿Extender la financiación de esta propuesta?')) return;

                                                const msg = document.getElementById('extender-msg');
                                                msg.textContent = 'Procesando...';
                                                msg.className = 'alert alert-secondary py-1 my-2';

                                                try {
                                                    const resp = await fetch('<%= request.getContextPath() %>/extenderFinanciacion?ajax=1&titulo=' + encodeURIComponent(titulo), {
                                                        method: 'POST'
                                                    });

                                                    const texto = await resp.text();
                                                    if (resp.ok) {
                                                        msg.textContent = texto && texto.trim().length ? texto : 'Financiación extendida correctamente.';
                                                        msg.className = 'alert alert-success py-1 my-2';
                                                    } else {
                                                        msg.textContent = 'No se pudo extender la financiación (HTTP ' + resp.status + ').';
                                                        msg.className = 'alert alert-danger py-1 my-2';
                                                    }
                                                } catch (e) {
                                                    msg.textContent = 'Error de red al extender la financiación.';
                                                    msg.className = 'alert alert-danger py-1 my-2';
                                                }
                                            }
                                        </script>





                                        </button>
                                                <% if (propuesta.getEstadoActual() != null && "FINANCIADA".equalsIgnoreCase(propuesta.getEstadoActual().name())) { %>
                                                    <form method="post" action="<%= request.getContextPath() %>/cancelarPropuesta" class="d-inline">
                                                        <input type="hidden" name="titulo" value="<%= propuesta.getTitulo() %>"/>
                                                        <input type="hidden" name="source" value="detail"/> <%-- Parámetro para saber que venimos del detalle --%>
                                                        <button type="submit" class="btn btn-danger"
                                                                onclick="return confirm('¿Estás seguro de que deseas cancelar esta propuesta?');">
                                                            <i class="bi bi-x-circle"></i> Cancelar Propuesta
                                                        </button>
                                                    </form>
                                                <% } else { %>
                                                    <%-- El botón está DESACTIVADO si la propuesta NO está financiada --%>
                                                    <button class="btn btn-danger" disabled>
                                                        <i class="bi bi-x-circle"></i> Cancelar Propuesta
                                                    </button>
                                                <% } %>
                                            </div>
                                            <p class="text-muted small">
                                                <em>Nota 1: Solo puedes extender la financiación si la propuesta está en estado "Publicada" o "En Financiación".<br>
                                                Nota 2: Solo puedes cancelar propuestas que se encuentren en estado "Financiada".</em>
                                            </p>

                                        <% } else if (haColaborado) { %>
                                    </div>

                                <% } else if (haColaborado) { %>
                                    <div class="d-flex gap-2 mb-3">
                                        <a href="<%= request.getContextPath() %>/comentario?titulo=<%=
                                            java.net.URLEncoder.encode(propuesta.getTitulo(), "UTF-8") %>"
                                           class="btn btn-info">
                                            <i class="bi bi-chat-dots"></i> Agregar Comentario
                                        </a>
                                    </div>
                                    <p class="text-muted small">
                                        <em>Como colaborador de esta propuesta, puedes agregar un comentario sobre tu experiencia.</em>
                                    </p>

                                <% } else if (!esProponente) { %>
                                    <div class="d-flex gap-2 mb-3">
                                        <a href="<%= request.getContextPath() %>/registrarColaboracion?titulo=<%= java.net.URLEncoder.encode(propuesta.getTitulo(), "UTF-8") %>"
                                           class="btn btn-success">
                                            <i class="bi bi-cash-coin"></i> Colaborar con esta Propuesta
                                        </a>
                                    </div>
                                <% } %>
                            <form action="<%= request.getContextPath() %>/marcarPropuestaFavorita" method="post">
                                <input type="hidden" name="titulo" value="<%= propuesta.getTitulo() %>">
                                <button type="submit" class="btn <%= esFavorita ? "btn-danger" : "btn-success" %>">
                                    <%= esFavorita ? "Quitar de Favoritas" : "Marcar Como Favorita" %>
                                </button>
                            </form>
                            <% } else { %>
                                <div class="alert alert-info">
                                    <p class="mb-2">Para colaborar con esta propuesta, debes iniciar sesión.</p>
                                    <a href="<%= request.getContextPath() %>/inicioDeSesion" class="btn btn-primary btn-sm">
                                        Iniciar Sesión
                                    </a>
                                </div>
                            <% } %>
                        </div>

                    <% } %>

                    <div class="text-center mt-4">
                        <a href="<%= request.getContextPath() %>/consultaPropuesta" class="btn btn-secondary">
                            Volver a la Lista
                        </a>
                        <a href="<%= request.getContextPath() %>/principal" class="btn btn-outline-secondary">
                            Ir al Inicio
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
