<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.servicios.cliente.propuestas.DtPropuesta, culturarte.servicios.cliente.usuario.DtUsuario, culturarte.servicios.cliente.imagenes.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agregar Comentario - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        .propuesta-info {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .comentario-form {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .char-counter {
            font-size: 12px;
            color: #6c757d;
        }
        .char-counter.warning {
            color: #fd7e14;
        }
        .char-counter.danger {
            color: #dc3545;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>
        
        <div class="py-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h3 class="text-center mb-0">
                            <i class="bi bi-chat-dots"></i> Agregar Comentario
                        </h3>
                        <p class="text-center mb-0 mt-2">
                            Comparte tu experiencia colaborando con esta propuesta
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
                        DtPropuesta propuesta = (DtPropuesta) request.getAttribute("propuesta");
                        DtUsuario usuario = (DtUsuario) request.getAttribute("usuario");
                        %>
                        
                        <% if (propuesta != null && usuario != null) { %>

                            <div class="propuesta-info">
                                <h5 class="mb-3">
                                    <i class="bi bi-info-circle"></i> Información de la Propuesta
                                </h5>
                                <div class="row">
                                    <div class="col-md-8">
                                        <h6><strong>Título:</strong> <%= propuesta.getTitulo() %></h6>
                                        <p class="mb-2"><strong>Descripción:</strong> <%= propuesta.getDescripcion() %></p>
                                        <p class="mb-2"><strong>Proponente:</strong> 
                                            <%= propuesta.getDTProponente() != null ? 
                                                propuesta.getDTProponente().getNickname() : "N/A" %>
                                        </p>
                                        <p class="mb-0"><strong>Monto necesario:</strong> 
                                            $<%= String.format("%.2f", propuesta.getMontoNecesario()) %>
                                        </p>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <% 
                                        String imagenPropuesta = propuesta.getImagen();
                                        boolean tieneImagen = imagenPropuesta != null && !imagenPropuesta.trim().isEmpty();
                                        %>
                                        
                                        <% if (tieneImagen) { %>
                                            <%
                                            // Llamar al Web Service SOAP para obtener la imagen en Base64
                                            ImagenWSEndpointService imagenServicio = new ImagenWSEndpointService();
                                            IImagenControllerWS imagenWS = imagenServicio.getImagenWSEndpointPort();
                                            String imagenDataUri = imagenWS.obtenerImagenBase64(imagenPropuesta);
                                            %>
                                            <img src="<%= imagenDataUri %>" 
                                                 class="img-fluid rounded" style="max-height: 120px; object-fit: cover;" 
                                                 alt="Imagen de <%= propuesta.getTitulo() %>"
                                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                       <% } else { %>
                                           <img src="<%= request.getContextPath() %>/imagenes/propuestaDefault.png"
                                                class="img-fluid rounded" style="max-height: 120px; object-fit: cover;"
                                                alt="Imagen por defecto">
                                       <% } %>
                                    </div>
                                </div>
                            </div>

                            <div class="comentario-form">
                                <form method="post" action="<%= request.getContextPath() %>/comentario" id="comentarioForm">
                                    <input type="hidden" name="tituloPropuesta" value="<%= propuesta.getTitulo() %>">
                                    
                                    <div class="mb-4">
                                        <label for="comentario" class="form-label">
                                            <strong>Tu Comentario</strong>
                                        </label>
                                        <textarea 
                                            class="form-control" 
                                            id="comentario" 
                                            name="comentario" 
                                            rows="6" 
                                            placeholder="Comparte tu experiencia colaborando con esta propuesta"
                                            maxlength="1000"
                                            required></textarea>
                                        <div class="char-counter mt-2">
                                            <span id="charCount">0</span>/1000 caracteres
                                        </div>
                                    </div>
                                    
                                    <div class="mb-4">
                                        <div class="alert alert-info" role="alert">
                                            <i class="bi bi-info-circle"></i>
                                            <strong>Importante:</strong> Tu comentario será visible para otros usuarios y ayudará a la comunidad a conocer más sobre esta propuesta.
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex gap-3 justify-content-center">
                                        <button type="submit" class="btn btn-primary btn-lg">
                                            <i class="bi bi-send"></i> Agregar Comentario
                                        </button>
                                        <a href="<%= request.getContextPath() %>/listarPropuestasParaComentar" class="btn btn-secondary btn-lg">
                                            <i class="bi bi-arrow-left"></i> Cancelar
                                        </a>
                                    </div>
                                </form>
                            </div>
                            
                        <% } else { %>
                            <div class="text-center py-5">
                                <div class="alert alert-warning" role="alert">
                                    <i class="bi bi-exclamation-triangle"></i>
                                    <strong>Error:</strong> No se pudo cargar la información de la propuesta.
                                </div>
                                <a href="<%= request.getContextPath() %>/listarPropuestasParaComentar" class="btn btn-primary">
                                    <i class="bi bi-arrow-left"></i> Volver a la Lista
                                </a>
                            </div>
                        <% } %>
                        
                        <div class="text-center mt-4">
                            <a href="<%= request.getContextPath() %>/principal" class="btn btn-outline-secondary">
                                <i class="bi bi-house"></i> Volver al Inicio
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const textarea = document.getElementById('comentario');
        const charCount = document.getElementById('charCount');
        const charCounter = document.querySelector('.char-counter');
        
        textarea.addEventListener('input', function() {
            const length = this.value.length;
            charCount.textContent = length;

            if (length > 800) {
                charCounter.className = 'char-counter danger mt-2';
            } else if (length > 600) {
                charCounter.className = 'char-counter warning mt-2';
            } else {
                charCounter.className = 'char-counter mt-2';
            }
        });
        

        document.getElementById('comentarioForm').addEventListener('submit', function(e) {
            const comentario = document.getElementById('comentario').value.trim();
            
            if (comentario.length < 10) {
                e.preventDefault();
                alert('El comentario debe tener al menos 10 caracteres.');
                return false;
            }
            
            if (comentario.length > 1000) {
                e.preventDefault();
                alert('El comentario no puede exceder 1000 caracteres.');
                return false;
            }
        });
    </script>
</body>
</html>
