<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.logica.DTs.DTPropuesta, culturarte.logica.DTs.DTUsuario, java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Detalle de Propuesta - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-5">
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
                        DTPropuesta propuesta = (DTPropuesta) request.getAttribute("propuesta");
                        Double montoRecaudado = (Double) request.getAttribute("montoRecaudado");
                        List<String> nicknamesColaboradores = (List<String>) request.getAttribute("nicknamesColaboradores");
                        Boolean esProponente = (Boolean) request.getAttribute("esProponente");
                        Boolean haColaborado = (Boolean) request.getAttribute("haColaborado");
                        DTUsuario usuarioActual = (DTUsuario) request.getAttribute("usuarioActual");
                        Boolean esFavorita = (Boolean) request.getAttribute("esFavorita");
                    %>
                    
                        <!-- Imagen de la propuesta -->
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
                                <!-- Siempre aparece error al cargar imagen con esto
                                <div class="bg-light d-flex align-items-center justify-content-center rounded" 
                                     style="height: 200px; display: none;">
                                    <span class="text-muted">Error al cargar imagen</span>
                                </div>
                                -->
                            </div>
                        <% } else { %>
                            <img src="<%= request.getContextPath() %>/imagenes/propuestaDefault.png"
                                class="card-img-top" style="height: 200px; object-fit: cover;"
                                alt="Imagen por defecto">
                        <% } %>
                        <!-- Información básica -->
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
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Información adicional -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h6>Proponente</h6>
                                <p><%= propuesta.getDTProponente() != null ? 
                                    propuesta.getDTProponente().getNickname() : "N/A" %></p>
                                
                                <h6>Lugar</h6>
                                <p><%= propuesta.getLugar() != null ? propuesta.getLugar() : "No especificado" %></p>
                                
                                <h6>Fecha Prevista</h6>
                                <p><%= propuesta.getFechaPrevista() != null ? 
                                    propuesta.getFechaPrevista() : "No especificada" %></p>
                            </div>
                            <div class="col-md-6">
                                <h6>Fecha de Publicación</h6>
                                <p><%= propuesta.getFechaPublicacion() != null ? 
                                    propuesta.getFechaPublicacion() : "No publicada" %></p>
                                
                                <h6>Categoría</h6>
                                <p><%= propuesta.getCategoria() != null ? 
                                    propuesta.getCategoria().getNombre() : "Sin categoría" %></p>
                                
                                <% if (propuesta.getPrecioEntrada() != null && propuesta.getPrecioEntrada() > 0) { %>
                                    <h6>Precio de Entrada</h6>
                                    <p>$<%= String.format("%.2f", propuesta.getPrecioEntrada()) %></p>
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- Colaboradores -->
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
                        
                        <!-- Acciones según el tipo de usuario -->
                        <div class="border-top pt-4">
                            <h6>Acciones Disponibles</h6>
                            
                            <% if (usuarioActual != null) { %>
                                <% if (esProponente) { %>
                                    <!-- Acciones para el proponente -->
                                    <div class="d-flex gap-2 mb-3">
                                        <button class="btn btn-warning" disabled>
                                            Extender Financiación
                                        </button>
                                        <button class="btn btn-danger" disabled>
                                            Cancelar Propuesta
                                        </button>
                                    </div>
                                    <p class="text-muted small">
                                        <em>Nota: Las acciones de extender financiación y cancelar propuesta
                                        se implementarán en otros casos de uso.</em>
                                    </p>

                                <% } else if (haColaborado) { %>
                                    <!-- Acciones para colaborador que ya colaboró -->
                                    <div class="d-flex gap-2 mb-3">
                                        <a href="<%= request.getContextPath() %>/formularioComentario?titulo=<%= 
                                            java.net.URLEncoder.encode(propuesta.getTitulo(), "UTF-8") %>" 
                                           class="btn btn-info">
                                            <i class="bi bi-chat-dots"></i> Agregar Comentario
                                        </a>
                                    </div>
                                    <p class="text-muted small">
                                        <em>Como colaborador de esta propuesta, puedes agregar un comentario sobre tu experiencia.</em>
                                    </p>
                                    
                                <% } else { %>
                                    <!-- Acciones para colaborador que no ha colaborado -->
                                    <div class="d-flex gap-2 mb-3">
                                        <button class="btn btn-success" disabled>
                                            Colaborar con esta Propuesta
                                        </button>
                                    </div>
                                    <p class="text-muted small">
                                        <em>Nota: La acción de registrar colaboración se implementará en otro caso de uso.</em>
                                    </p>
                                <% } %>
                            <form action="<%= request.getContextPath() %>/marcarPropuestaFavorita" method="post">
                                <input type="hidden" name="titulo" value="<%= propuesta.getTitulo() %>">
                                <button type="submit" class="btn <%= esFavorita ? "btn-danger" : "btn-success" %>">
                                    <%= esFavorita ? "Quitar de Favoritas" : "Marcar Como Favorita" %>
                                </button>
                            </form>
                            <% } else { %>
                                <!-- Usuario no logueado -->
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
