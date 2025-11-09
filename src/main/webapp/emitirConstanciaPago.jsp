<%@ page import="java.util.*, culturarte.servicios.cliente.usuario.DtColaboracion, culturarte.servicios.cliente.usuario.DtColaborador, com.culturarteWeb.util.WSFechaUsuario, java.time.format.DateTimeFormatter, java.time.LocalDate, java.time.LocalDateTime" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Constancia de Pago - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        body {
            background-color: #f5f5f5;
            padding-top: 20px;
        }
        .constancia-container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .constancia-header {
            text-align: center;
            border-bottom: 3px solid #333;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .constancia-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .constancia-platform {
            font-size: 18px;
            color: #666;
        }
        .constancia-section {
            margin-bottom: 30px;
        }
        .constancia-section-title {
            font-size: 18px;
            font-weight: bold;
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .constancia-row {
            display: flex;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .constancia-label {
            font-weight: bold;
            width: 200px;
            flex-shrink: 0;
        }
        .constancia-value {
            flex: 1;
        }
        .constancia-footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #ddd;
            text-align: center;
            font-size: 12px;
            color: #666;
        }
        @media print {
            .no-print {
                display: none;
            }
            .constancia-container {
                box-shadow: none;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="cabezalComun.jsp"/>

    <div class="container mt-4">
        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-danger" role="alert">
                <%= error %>
            </div>
        <% } else { %>
            <% 
                DtColaboracion colaboracion = (DtColaboracion) request.getAttribute("colaboracion");
                DtColaborador colaborador = (DtColaborador) request.getAttribute("colaborador");
                LocalDate fechaEmision = (LocalDate) request.getAttribute("fechaEmision");
                LocalDateTime fechaHoraColaboracion = (LocalDateTime) request.getAttribute("fechaHoraColaboracion");
                
                DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                
                String tituloPropuesta = colaboracion.getPropuesta() != null ? colaboracion.getPropuesta().getTitulo() : "Sin título";
                String fechaEmisionStr = fechaEmision != null ? fechaEmision.format(dateFormatter) : "N/A";
                String fechaHoraColaboracionStr = fechaHoraColaboracion != null ? fechaHoraColaboracion.format(dateTimeFormatter) : "N/A";
                Double monto = colaboracion.getMonto() != null ? colaboracion.getMonto() : 0.0;
            %>

            <div class="constancia-container">
                <!-- Encabezado -->
                <div class="constancia-header">
                    <div class="constancia-title">CONSTANCIA DE PAGO DE COLABORACIÓN</div>
                    <div class="constancia-platform">Plataforma Culturarte</div>
                </div>

                <!-- Fecha de emisión -->
                <div class="text-end mb-4">
                    <strong>Fecha de emisión:</strong> <%= fechaEmisionStr %>
                </div>

                <!-- Datos del Colaborador -->
                <div class="constancia-section">
                    <div class="constancia-section-title">Datos del Colaborador</div>
                    <div class="constancia-row">
                        <div class="constancia-label">Nickname:</div>
                        <div class="constancia-value"><%= colaborador.getNickname() %></div>
                    </div>
                    <div class="constancia-row">
                        <div class="constancia-label">Nombre:</div>
                        <div class="constancia-value"><%= colaborador.getNombre() %> <%= colaborador.getApellido() %></div>
                    </div>
                    <div class="constancia-row">
                        <div class="constancia-label">Correo:</div>
                        <div class="constancia-value"><%= colaborador.getCorreo() != null ? colaborador.getCorreo() : "N/A" %></div>
                    </div>
                    <% if (colaborador.getFechaNacimiento() != null) {
                        try {
                            java.time.LocalDate fechaNac = WSFechaUsuario.toJavaLocalDate(colaborador.getFechaNacimiento());
                            if (fechaNac != null) {
                    %>
                    <div class="constancia-row">
                        <div class="constancia-label">Fecha de Nacimiento:</div>
                        <div class="constancia-value"><%= fechaNac.format(dateFormatter) %></div>
                    </div>
                    <%      }
                        } catch (Exception e) { }
                    } %>
                </div>

                <!-- Datos de la Colaboración -->
                <div class="constancia-section">
                    <div class="constancia-section-title">Datos de la Colaboración</div>
                    <div class="constancia-row">
                        <div class="constancia-label">Propuesta:</div>
                        <div class="constancia-value"><%= tituloPropuesta %></div>
                    </div>
                    <div class="constancia-row">
                        <div class="constancia-label">Monto:</div>
                        <div class="constancia-value">$<%= String.format("%.2f", monto) %></div>
                    </div>
                    <div class="constancia-row">
                        <div class="constancia-label">Fecha y Hora:</div>
                        <div class="constancia-value"><%= fechaHoraColaboracionStr %></div>
                    </div>
                    <% if (colaboracion.getTipoRetorno() != null) { %>
                    <div class="constancia-row">
                        <div class="constancia-label">Tipo de Retorno:</div>
                        <div class="constancia-value"><%= colaboracion.getTipoRetorno().toString() %></div>
                    </div>
                    <% } %>
                </div>

                <!-- Datos del Pago -->
                <div class="constancia-section">
                    <div class="constancia-section-title">Datos del Pago</div>
                    <div class="constancia-row">
                        <div class="constancia-label">Monto Pagado:</div>
                        <div class="constancia-value">$<%= String.format("%.2f", monto) %></div>
                    </div>
                    <div class="constancia-row">
                        <div class="constancia-label">Estado:</div>
                        <div class="constancia-value">Pagado</div>
                    </div>
                    <div class="constancia-row">
                        <div class="constancia-label">Fecha de Pago:</div>
                        <div class="constancia-value"><%= fechaHoraColaboracionStr %></div>
                    </div>
                </div>

                <!-- Pie de página -->
                <div class="constancia-footer">
                    Este documento es una constancia oficial emitida por la plataforma Culturarte.
                </div>
            </div>

            <!-- Botones de acción -->
            <div class="text-center mt-4 no-print">
                <a href="<%= request.getContextPath() %>/generarPDFConstancia?tituloPropuesta=<%= java.net.URLEncoder.encode(tituloPropuesta, "UTF-8") %>" 
                   class="btn btn-primary btn-lg me-2" target="_blank">
                    Descargar PDF
                </a>
                <button onclick="window.print()" class="btn btn-secondary btn-lg me-2">
                    Imprimir
                </button>
                <a href="<%= request.getContextPath() %>/listarColaboracionesConstancia" class="btn btn-outline-secondary btn-lg">
                    Volver
                </a>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

