<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, culturarte.servicios.cliente.propuestas.DtPropuesta, culturarte.servicios.cliente.propuestas.DtUsuario" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comentar Propuestas - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        .propuesta-card {
            transition: transform 0.2s ease-in-out;
        }
        .propuesta-card:hover {
            transform: translateY(-5px);
        }
        .estado-financiada {
            background-color: #d4edda;
            color: #155724;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>
        
        <div class="py-5">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h3 class="text-center mb-0">
                            <i class="bi bi-chat-dots"></i> Propuestas para Comentar
                        </h3>
                        <p class="text-center mb-0 mt-2">
                            Selecciona una propuesta financiada con la que colaboraste para agregar tu comentario
                        </p>
                    </div>
                    <div class="card-body">
                        
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger" role="alert">
                                <i class="bi bi-exclamation-triangle"></i>
                                <%= request.getAttribute("error") %>
                            </div>
                        <% } %>
                        
                        <% 
                        List<DtPropuesta> propuestas = (List<DtPropuesta>) request.getAttribute("propuestasParaComentar");
                        DtUsuario usuario = (DtUsuario) request.getAttribute("usuario");
                        %>
                        
                        <% if (propuestas != null && !propuestas.isEmpty()) { %>
                            <div class="alert alert-info" role="alert">
                                <i class="bi bi-info-circle"></i>
                                <strong>¡Hola <%= usuario.getNombre() %>!</strong> 
                                Encontraste <%= propuestas.size() %> propuesta(s) financiada(s) con las que colaboraste y puedes comentar.
                            </div>
                            
                            <div class="row">
                                <% for (DtPropuesta propuesta : propuestas) { %>
                                    <div class="col-md-6 mb-4">
                                        <div class="card propuesta-card h-100">
                                            <% 
                                            String imagenPropuesta = propuesta.getImagen();
                                            boolean tieneImagen = imagenPropuesta != null && !imagenPropuesta.trim().isEmpty();
                                            %>
                                            
                                            <% if (tieneImagen) { %>
                                                <img src="<%= request.getContextPath() %>/<%= imagenPropuesta %>" 
                                                     class="card-img-top" style="height: 400px; object-fit: cover;"
                                                     alt="Imagen de <%= propuesta.getTitulo() %>"
                                                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                           <% } else { %>
                                               <img src="<%= request.getContextPath() %>/imagenes/propuestaDefault.png"
                                                    class="card-img-top" style="height: 200px; object-fit: cover;"
                                                    alt="Imagen por defecto">
                                           <% } %>
                                            
                                            <div class="card-body d-flex flex-column">
                                                <h5 class="card-title"><%= propuesta.getTitulo() %></h5>
                                                <p class="card-text text-muted">
                                                    <%= propuesta.getDescripcion().length() > 120 ? 
                                                        propuesta.getDescripcion().substring(0, 120) + "..." : 
                                                        propuesta.getDescripcion() %>
                                                </p>
                                                
                                                <div class="mb-3">
                                                    <span class="estado-financiada">
                                                        ✓ FINANCIADA
                                                    </span>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <strong>Monto necesario:</strong> 
                                                    $<%= String.format("%.2f", propuesta.getMontoNecesario()) %>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <strong>Proponente:</strong> 
                                                    <%= propuesta.getDTProponente() != null ? 
                                                        propuesta.getDTProponente().getNickname() : "N/A" %>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <strong>Fecha publicación:</strong> 
                                                    <% 
                                                        if (propuesta.getFechaPublicacion() != null) {
                                                            java.time.LocalDate fechaPublicacion = com.culturarteWeb.util.WSFechaPropuesta.toJavaLocalDate(propuesta.getFechaPublicacion());
                                                            out.print(fechaPublicacion != null ? fechaPublicacion.toString() : "N/A");
                                                        } else {
                                                            out.print("N/A");
                                                        }
                                                    %>
                                                </div>
                                                
                                                <div class="mt-auto">
                                                    <a href="<%= request.getContextPath() %>/comentario?titulo=<%= 
                                                        java.net.URLEncoder.encode(propuesta.getTitulo(), "UTF-8") %>" 
                                                       class="btn btn-primary w-100">
                                                        <i class="bi bi-chat-dots"></i> Agregar Comentario
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                        <% } else { %>
                            <div class="text-center py-5">
                                <div class="mb-4">
                                    <i class="bi bi-chat-dots" style="font-size: 4rem; color: #6c757d;"></i>
                                </div>
                                <h4 class="text-muted">No hay propuestas disponibles para comentar</h4>
                                <p class="text-muted">
                                    No tienes propuestas financiadas con las que hayas colaborado y que aún no hayas comentado.
                                </p>
                                <a href="<%= request.getContextPath() %>/principal" class="btn btn-primary">
                                    <i class="bi bi-house"></i> Volver al Inicio
                                </a>
                            </div>
                        <% } %>
                        
                        <div class="text-center mt-4">
                            <a href="<%= request.getContextPath() %>/principal" class="btn btn-secondary">
                                <i class="bi bi-arrow-left"></i> Volver al Inicio
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
