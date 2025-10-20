<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="culturarte.logica.modelos.Propuesta" %>
<%@ page import="culturarte.logica.DTs.DTUsuario" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ejecutar Propuestas - CulturArte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .propuesta-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-bottom: 20px;
            transition: box-shadow 0.3s;
        }
        .propuesta-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .estado-badge {
            font-size: 0.8em;
            padding: 4px 8px;
        }
    </style>
</head>
<body>
    <%@ include file="cabezalComun.jsp" %>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2><i class="bi bi-play-circle"></i> Ejecutar Propuestas</h2>
                <p class="text-muted">Marca tus propuestas financiadas como ejecutadas una vez que las hayas llevado a cabo.</p>
                
                <% if (request.getAttribute("mensaje") != null) { %>
                    <div class="alert alert-info alert-dismissible fade show" role="alert">
                        <%= request.getAttribute("mensaje") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <%
                    List<Propuesta> propuestas = (List<Propuesta>) request.getAttribute("propuestas");
                    if (propuestas == null || propuestas.isEmpty()) {
                %>
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle"></i>
                        No tienes propuestas financiadas pendientes de ejecutar.
                    </div>
                <% } else { %>
                    
                    <div class="row">
                        <% for (Propuesta propuesta : propuestas) { %>
                            <div class="col-md-6 col-lg-4">
                                <div class="card propuesta-card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h6 class="mb-0"><%= propuesta.getTitulo() %></h6>
                                        <span class="badge bg-success estado-badge">
                                            <%= propuesta.getEstadoActual().toString() %>
                                        </span>
                                    </div>
                                    
                                    <div class="card-body">
                                        <p class="card-text">
                                            <strong>Descripción:</strong><br>
                                            <%= propuesta.getDescripcion().length() > 100 ? 
                                                propuesta.getDescripcion().substring(0, 100) + "..." : 
                                                propuesta.getDescripcion() %>
                                        </p>
                                        
                                        <div class="row text-muted small mb-3">
                                            <div class="col-6">
                                                <i class="bi bi-geo-alt"></i> <%= propuesta.getLugar() %>
                                            </div>
                                            <div class="col-6">
                                                <i class="bi bi-calendar"></i> <%= propuesta.getFechaPrevista() != null ? propuesta.getFechaPrevista() : "No especificada" %>
                                            </div>
                                        </div>
                                        
                                        <div class="row text-muted small mb-3">
                                            <div class="col-12">
                                                <i class="bi bi-currency-dollar"></i> 
                                                Monto necesario: $<%= String.format("%.2f", propuesta.getMontoNecesario()) %>
                                            </div>
                                        </div>

                                        <% if (propuesta.getImagen() != null && !propuesta.getImagen().isEmpty()) { %>
                                            <img src="<%= request.getContextPath() %>/<%= propuesta.getImagen() %>" 
                                                 class="img-fluid rounded mb-3" 
                                                 style="max-height: 150px; width: 100%; object-fit: cover;"
                                                 alt="Imagen de <%= propuesta.getTitulo() %>">
                                        <% } %>
                                    </div>
                                    
                                    <div class="card-footer">
                                        <form action="<%= request.getContextPath() %>/ejecutarPropuesta" method="post">
                                            <input type="hidden" name="titulo" value="<%= propuesta.getTitulo() %>">
                                            
                                            <button type="submit" class="btn btn-success w-100"
                                                    onclick="return confirm('¿Estás seguro de que deseas marcar esta propuesta como ejecutada?')">
                                                <i class="bi bi-play-circle"></i> Marcar como Ejecutada
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
                
                <div class="mt-4">
                    <a href="<%= request.getContextPath() %>/principal" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Volver al Inicio
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
