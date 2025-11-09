<%@ page import="java.util.*, culturarte.servicios.cliente.usuario.DtColaboracion, culturarte.servicios.cliente.usuario.DtColaborador, com.culturarteWeb.util.WSFechaUsuario, java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Constancias de Pago - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        body {
            background-color: #f5f5f5;
            padding-top: 20px;
        }
        .card {
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .colaboracion-item {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            background-color: white;
        }
        .colaboracion-item:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        .propuesta-imagen {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <jsp:include page="cabezalComun.jsp"/>

    <div class="container mt-4">
        <h1 class="mb-4">Constancias de Pago de Colaboración</h1>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-danger" role="alert">
                <%= error %>
            </div>
        <% } %>

        <% 
            List<DtColaboracion> colaboraciones = (List<DtColaboracion>) request.getAttribute("colaboraciones");
            if (colaboraciones == null) {
                colaboraciones = new ArrayList<>();
            }
        %>

        <% if (colaboraciones.isEmpty()) { %>
            <div class="alert alert-info" role="alert">
                <h4>No hay colaboraciones con pago asociado</h4>
                <p>No se encontraron colaboraciones que tengan un pago asociado para las cuales pueda generar una constancia.</p>
            </div>
        <% } else { %>
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Colaboraciones Disponibles para Constancia</h5>
                </div>
                <div class="card-body">
                    <p class="text-muted">Seleccione una colaboración para generar su constancia de pago:</p>
                    
                    <% for (DtColaboracion colab : colaboraciones) { 
                        String tituloPropuesta = colab.getPropuesta() != null ? colab.getPropuesta().getTitulo() : "Sin título";
                        String imagenPropuesta = colab.getPropuesta() != null && colab.getPropuesta().getImagen() != null && !colab.getPropuesta().getImagen().isEmpty() 
                            ? request.getContextPath() + "/" + colab.getPropuesta().getImagen() 
                            : request.getContextPath() + "/imagenes/propuestaDefault.png";
                        Double monto = colab.getMonto() != null ? colab.getMonto() : 0.0;
                        String fechaHoraStr = "No disponible";
                        
                        if (colab.getFechaHora() != null) {
                            try {
                                java.time.LocalDateTime fechaHora = WSFechaUsuario.toJavaLocalDateTime(colab.getFechaHora());
                                if (fechaHora != null) {
                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                                    fechaHoraStr = fechaHora.format(formatter);
                                }
                            } catch (Exception e) {
                                fechaHoraStr = "Fecha no disponible";
                            }
                        }
                    %>
                        <div class="colaboracion-item">
                            <div class="row align-items-center">
                                <div class="col-md-2 text-center">
                                    <img src="<%= imagenPropuesta %>" alt="<%= tituloPropuesta %>" class="propuesta-imagen">
                                </div>
                                <div class="col-md-6">
                                    <h5><%= tituloPropuesta %></h5>
                                    <p class="text-muted mb-1">
                                        <strong>Fecha de colaboración:</strong> <%= fechaHoraStr %>
                                    </p>
                                    <p class="text-muted mb-0">
                                        <strong>Monto:</strong> $<%= String.format("%.2f", monto) %>
                                    </p>
                                </div>
                                <div class="col-md-4 text-end">
                                    <a href="<%= request.getContextPath() %>/emitirConstanciaPago?tituloPropuesta=<%= java.net.URLEncoder.encode(tituloPropuesta, "UTF-8") %>" 
                                       class="btn btn-primary">
                                        Generar Constancia
                                    </a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>

        <div class="mt-3">
            <a href="<%= request.getContextPath() %>/consultaPerfilUsuario" class="btn btn-secondary">
                Volver al Perfil
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

