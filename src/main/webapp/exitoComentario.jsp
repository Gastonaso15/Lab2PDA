<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comentario Agregado - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        .success-icon {
            font-size: 4rem;
            color: #28a745;
        }
        .success-card {
            border-left: 5px solid #28a745;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>
        
        <div class="py-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow-sm success-card">
                    <div class="card-body text-center py-5">
                        
                        <div class="mb-4">
                            <i class="bi bi-check-circle success-icon"></i>
                        </div>
                        
                        <% if (request.getAttribute("mensajeExito") != null) { %>
                            <h3 class="text-success mb-4">
                                ¡Comentario Agregado Exitosamente!
                            </h3>
                            <div class="alert alert-success" role="alert">
                                <i class="bi bi-info-circle"></i>
                                <%= request.getAttribute("mensajeExito") %>
                            </div>
                        <% } else { %>
                            <h3 class="text-success mb-4">
                                ¡Operación Completada!
                            </h3>
                            <div class="alert alert-success" role="alert">
                                <i class="bi bi-info-circle"></i>
                                Tu comentario ha sido registrado exitosamente en el sistema.
                            </div>
                        <% } %>
                        
                        <p class="text-muted mb-4">
                            Gracias por compartir tu experiencia con la comunidad. 
                            Tu comentario ayudará a otros usuarios a conocer más sobre esta propuesta.
                        </p>
                        
                        <div class="d-flex gap-3 justify-content-center flex-wrap">
                            <a href="<%= request.getContextPath() %>/listarPropuestasParaComentar" class="btn btn-primary">
                                <i class="bi bi-chat-dots"></i> Ver Otras Propuestas
                            </a>
                            <a href="<%= request.getContextPath() %>/principal" class="btn btn-outline-primary">
                                <i class="bi bi-house"></i> Volver al Inicio
                            </a>
                        </div>
                        
                        <div class="mt-4">
                            <small class="text-muted">
                                <i class="bi bi-clock"></i>
                                Tu comentario está ahora disponible para la comunidad.
                            </small>
                        </div>
                    </div>
                </div>
                
                <!-- Información adicional -->
                <div class="card mt-4">
                    <div class="card-body">
                        <h6 class="card-title">
                            <i class="bi bi-lightbulb"></i> ¿Qué puedes hacer ahora?
                        </h6>
                        <ul class="list-unstyled mb-0">
                            <li class="mb-2">
                                <i class="bi bi-arrow-right text-primary"></i>
                                <strong>Explorar más propuestas:</strong> Descubre otras propuestas culturales disponibles
                            </li>
                            <li class="mb-2">
                                <i class="bi bi-arrow-right text-primary"></i>
                                <strong>Colaborar nuevamente:</strong> Encuentra nuevas propuestas que te interesen
                            </li>
                            <li class="mb-0">
                                <i class="bi bi-arrow-right text-primary"></i>
                                <strong>Compartir tu experiencia:</strong> Ayuda a otros colaboradores con tus comentarios
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
