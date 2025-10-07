<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Debug Context Path</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header">
                    <h3 class="text-center mb-0">Debug - Context Path</h3>
                </div>
                <div class="card-body">
                    
                    <h5>Información del Context Path:</h5>
                    <ul>
                        <li><strong>Context Path:</strong> "<%= request.getContextPath() %>"</li>
                        <li><strong>Request URI:</strong> <%= request.getRequestURI() %></li>
                        <li><strong>Server Name:</strong> <%= request.getServerName() %></li>
                        <li><strong>Server Port:</strong> <%= request.getServerPort() %></li>
                        <li><strong>Scheme:</strong> <%= request.getScheme() %></li>
                    </ul>
                    
                    <h5>URLs de prueba para imágenes:</h5>
                    <ul>
                        <li><strong>Propuesta 1:</strong> <a href="<%= request.getContextPath() %>/uploads/propuestas/Imagen1.jpg" target="_blank"><%= request.getContextPath() %>/uploads/propuestas/Imagen1.jpg</a></li>
                        <li><strong>Propuesta 2:</strong> <a href="<%= request.getContextPath() %>/uploads/propuestas/Imagen2.jpg" target="_blank"><%= request.getContextPath() %>/uploads/propuestas/Imagen2.jpg</a></li>
                        <li><strong>Usuario 1:</strong> <a href="<%= request.getContextPath() %>/uploads/usuarios/ImagenUP1.jpg" target="_blank"><%= request.getContextPath() %>/uploads/usuarios/ImagenUP1.jpg</a></li>
                    </ul>
                    
                    <h5>Imágenes de prueba:</h5>
                    <div class="row">
                        <div class="col-md-4">
                            <h6>Propuesta 1</h6>
                            <img src="<%= request.getContextPath() %>/uploads/propuestas/Imagen1.jpg" 
                                 class="img-fluid" style="max-height: 150px;" 
                                 alt="Imagen 1"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <div class="bg-light d-flex align-items-center justify-content-center" 
                                 style="height: 150px; display: none;">
                                <span class="text-muted">Error al cargar imagen</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <h6>Propuesta 2</h6>
                            <img src="<%= request.getContextPath() %>/uploads/propuestas/Imagen2.jpg" 
                                 class="img-fluid" style="max-height: 150px;" 
                                 alt="Imagen 2"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <div class="bg-light d-flex align-items-center justify-content-center" 
                                 style="height: 150px; display: none;">
                                <span class="text-muted">Error al cargar imagen</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <h6>Usuario 1</h6>
                            <img src="<%= request.getContextPath() %>/uploads/usuarios/ImagenUP1.jpg" 
                                 class="img-fluid" style="max-height: 150px;" 
                                 alt="Imagen UP1"
                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <div class="bg-light d-flex align-items-center justify-content-center" 
                                 style="height: 150px; display: none;">
                                <span class="text-muted">Error al cargar imagen</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="text-center mt-4">
                        <a href="<%= request.getContextPath() %>/principal.jsp" class="btn btn-secondary">
                            Volver al Inicio
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
