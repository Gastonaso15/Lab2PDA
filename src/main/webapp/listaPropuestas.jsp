<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, culturarte.logica.DTs.DTPropuesta" %>
<!DOCTYPE html>
<html>
<head>
    <title>Consulta de Propuestas - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <div class="card shadow-sm">
                <div class="card-header">
                    <h3 class="text-center mb-0">Consulta de Propuestas</h3>
                </div>
                <div class="card-body">
                    
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger" role="alert">
                            <%= request.getAttribute("error") %>
                        </div>
                    <% } %>
                    
                    <% List<DTPropuesta> propuestas = (List<DTPropuesta>) request.getAttribute("propuestas");
                    if (propuestas != null && !propuestas.isEmpty()) { %>
                        
                        <div class="row">
                            <% for (DTPropuesta propuesta : propuestas) { %>
                                <div class="col-md-6 mb-4">
                                    <div class="card h-100">
                                        <% 
                                        String imagenPropuesta = propuesta.getImagen();
                                        boolean tieneImagen = imagenPropuesta != null && !imagenPropuesta.trim().isEmpty();
                                        %>
                                        
                                        <% if (tieneImagen) { %>
                                            <%
                                            String contextPath = request.getContextPath();
                                            String imagenUrl = contextPath + "/" + imagenPropuesta;
                                            System.out.println("Context Path: " + contextPath);
                                            System.out.println("Imagen Propuesta: " + imagenPropuesta);
                                            System.out.println("URL Final: " + imagenUrl);
                                            %>
                                            <img src="<%= imagenUrl %>" 
                                                 class="card-img-top" style="height: 200px; object-fit: cover;" 
                                                 alt="Imagen de <%= propuesta.getTitulo() %>"
                                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                            <!-- Siempre aparece error al cargar imagen con esto
                                            <div class="card-img-top bg-light d-flex align-items-center justify-content-center"
                                                 style="height: 200px; display: none;">
                                                <span class="text-muted">Error al cargar imagen</span>
                                            </div>
                                            -->
                                       <% } else { %>
                                           <img src="<%= request.getContextPath() %>/imagenes/propuestaDefault.png"
                                                class="card-img-top" style="height: 200px; object-fit: cover;"
                                                alt="Imagen por defecto">
                                       <% } %>
                                        <div class="card-body">
                                            <h5 class="card-title"><%= propuesta.getTitulo() %></h5>
                                            <p class="card-text text-muted">
                                                <%= propuesta.getDescripcion().length() > 100 ? 
                                                    propuesta.getDescripcion().substring(0, 100) + "..." : 
                                                    propuesta.getDescripcion() %>
                                            </p>
                                            
                                            <div class="mb-2">
                                                <strong>Estado:</strong> 
                                                <span class="badge bg-primary"><%= propuesta.getEstadoActual() %></span>
                                            </div>
                                            
                                            <div class="mb-2">
                                                <strong>Monto necesario:</strong> 
                                                $<%= String.format("%.2f", propuesta.getMontoNecesario()) %>
                                            </div>
                                            
                                            <div class="mb-2">
                                                <strong>Proponente:</strong> 
                                                <%= propuesta.getDTProponente() != null ? 
                                                    propuesta.getDTProponente().getNickname() : "N/A" %>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <strong>Fecha publicación:</strong> 
                                                <%= propuesta.getFechaPublicacion() != null ? 
                                                    propuesta.getFechaPublicacion() : "N/A" %>
                                            </div>
                                            
                                            <a href="<%= request.getContextPath() %>/consultaPropuesta?accion=detalle&titulo=<%= 
                                                java.net.URLEncoder.encode(propuesta.getTitulo(), "UTF-8") %>" 
                                               class="btn btn-primary w-100">
                                                Ver Detalles
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                        
                    <% } else { %>
                        <div class="text-center py-5">
                            <h4 class="text-muted">No hay propuestas disponibles</h4>
                            <p class="text-muted">No se encontraron propuestas para mostrar.</p>
                        </div>
                    <% } %>
                    
                    <div class="text-center mt-4">
                        <a href="<%= request.getContextPath() %>/principal" class="btn btn-secondary">
                            Volver al Inicio
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