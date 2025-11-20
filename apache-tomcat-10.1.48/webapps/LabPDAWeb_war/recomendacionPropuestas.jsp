<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, culturarte.servicios.cliente.propuestas.DtPropuesta, culturarte.servicios.cliente.imagenes.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recomendaciones de Propuestas - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        body {
            background-color: #f5f5f5;
            color: #333;
            font-family: 'Arial', sans-serif;
        }
        .cartaPropuesta {
            display: flex;
            flex-direction: column;
            border-radius: 8px;
            background-color: white;
            overflow: hidden;
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
            border: 1px solid #ddd;
        }
        .cartaPropuesta:hover {
            transform: translateY(-5px);
            box-shadow: 0 1rem 3rem rgba(0, 0, 0, .175) !important;
        }
        .imagenPropuesta {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .contenidoPropuesta {
            padding: 15px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        .tituloPropuesta {
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .descripcionPropuesta {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 15px;
            flex-grow: 1;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .progreso-financiacion {
            margin-bottom: 15px;
        }
        .info-progreso {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-size: 0.85rem;
            color: #666;
        }
        .puntaje-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: bold;
            background-color: #28a745;
            color: white;
            margin-bottom: 10px;
        }
        .puntaje-info {
            font-size: 0.8rem;
            color: #666;
            margin-bottom: 5px;
        }
        .badge-detalle {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 0.75rem;
            background-color: #e9ecef;
            color: #495057;
            margin-right: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>

        <div class="py-5">
            <div class="row justify-content-center">
                <div class="col-12">
                    <div class="card shadow-sm mb-4">
                        <div class="card-header bg-primary text-white">
                            <h3 class="text-center mb-0">
                                <span>⭐</span> Recomendaciones de Propuestas
                            </h3>
                        </div>
                        <div class="card-body">
                            <% if (request.getAttribute("error") != null) { %>
                                <div class="alert alert-danger" role="alert">
                                    <%= request.getAttribute("error") %>
                                </div>
                            <% } else { %>
                                <%
                                    List<DtPropuesta> propuestasRecomendadas =
                                        (List<DtPropuesta>) request.getAttribute("propuestasRecomendadas");
                                    Map<String, Map<String, Object>> puntajesPorPropuesta =
                                        (Map<String, Map<String, Object>>) request.getAttribute("puntajesPorPropuesta");
                                    Integer totalCandidatas = (Integer) request.getAttribute("totalCandidatas");

                                    if (propuestasRecomendadas == null || propuestasRecomendadas.isEmpty() || puntajesPorPropuesta == null) {
                                %>
                                    <div class="alert alert-info" role="alert">
                                        <h5>No hay recomendaciones disponibles</h5>
                                        <p>No se encontraron propuestas similares a las que has colaborado.
                                        Intenta seguir más usuarios o colaborar en más propuestas para obtener recomendaciones personalizadas.</p>
                                        <a href="<%= request.getContextPath() %>/consultaPropuesta" class="btn btn-primary">
                                            Ver todas las propuestas
                                        </a>
                                    </div>
                                <% } else { %>
                                    <div class="alert alert-success" role="alert">
                                        <strong>¡Encontradas <%= propuestasRecomendadas.size() %> propuestas recomendadas!</strong>
                                        <% if (totalCandidatas != null) { %>
                                            <br><small>Basadas en <%= totalCandidatas %> propuestas similares a las que has colaborado.</small>
                                        <% } %>
                                    </div>

                                    <div class="row">
                                        <%
                                            for (DtPropuesta p : propuestasRecomendadas) {
                                                Map<String, Object> detalles = puntajesPorPropuesta.get(p.getTitulo());

                                                if (detalles == null) continue;

                                                Integer puntajeTotal = (Integer) detalles.get("puntajeTotal");
                                                Integer cantidadColaboradores = (Integer) detalles.get("cantidadColaboradores");
                                                Integer puntajeFinanciacion = (Integer) detalles.get("puntajeFinanciacion");
                                                Integer cantidadFavoritos = (Integer) detalles.get("cantidadFavoritos");
                                                Double montoRecaudado = (Double) detalles.get("montoRecaudado");
                                                Double porcentajeFinanciacion = (Double) detalles.get("porcentajeFinanciacion");

                                                String imagen;
                                                if (p.getImagen() != null && !p.getImagen().isEmpty()) {
                                                    // Llamar al Web Service SOAP para obtener la imagen en Base64
                                                    ImagenWSEndpointService imagenServicio = new ImagenWSEndpointService();
                                                    IImagenControllerWS imagenWS = imagenServicio.getImagenWSEndpointPort();
                                                    imagen = imagenWS.obtenerImagenBase64(p.getImagen());
                                                } else {
                                                    imagen = request.getContextPath() + "/imagenes/propuestaDefault.png";
                                                }

                                                double porcentajeProgreso = porcentajeFinanciacion != null ? porcentajeFinanciacion : 0.0;
                                                if (porcentajeProgreso > 100) porcentajeProgreso = 100;
                                                long porcentajeRedondeado = Math.round(porcentajeProgreso);
                                        %>
                                        <div class="col-12 col-md-6 col-lg-4 d-flex mb-4">
                                            <div class="cartaPropuesta h-100 shadow-sm w-100">
                                                <img src="<%= imagen %>" class="imagenPropuesta" alt="Imagen de <%= p.getTitulo() %>">

                                                <div class="contenidoPropuesta">
                                                    <div class="tituloPropuesta"><%= p.getTitulo() %></div>
                                                    <div class="descripcionPropuesta"><%= p.getDescripcion() != null ? p.getDescripcion() : "" %></div>

                                                    <div class="puntaje-badge">
                                                        Puntaje: <%= puntajeTotal != null ? puntajeTotal : 0 %>
                                                    </div>

                                                    <div class="puntaje-info">
                                                        <span class="badge-detalle">
                                                            👥 <%= cantidadColaboradores != null ? cantidadColaboradores : 0 %> colaboradores
                                                        </span>
                                                        <span class="badge-detalle">
                                                            💰 Puntaje financiación: <%= puntajeFinanciacion != null ? puntajeFinanciacion : 0 %>
                                                        </span>
                                                        <span class="badge-detalle">
                                                            ⭐ <%= cantidadFavoritos != null ? cantidadFavoritos : 0 %> favoritos
                                                        </span>
                                                    </div>

                                                    <div class="progreso-financiacion">
                                                        <div class="info-progreso">
                                                            <span>$<%= String.format("%.0f", montoRecaudado != null ? montoRecaudado : 0.0) %> recaudado</span>
                                                            <span><%= porcentajeRedondeado %>%</span>
                                                        </div>

                                                        <div class="progress" style="height: 8px;">
                                                            <div class="progress-bar" role="progressbar"
                                                                 style="width: <%= porcentajeRedondeado %>%"
                                                                 aria-valuenow="<%= porcentajeRedondeado %>"
                                                                 aria-valuemin="0"
                                                                 aria-valuemax="100">
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="mt-auto">
                                                        <a href="<%= request.getContextPath() %>/consultaPropuesta?accion=detalle&titulo=<%= java.net.URLEncoder.encode(p.getTitulo(), "UTF-8") %>"
                                                           class="btn btn-primary w-100">
                                                            Ver Detalle
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <% } %>
                                    </div>
                                <% } %>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>