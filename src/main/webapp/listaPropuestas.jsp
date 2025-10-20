<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, culturarte.logica.DTs.DTPropuesta" %>
<!DOCTYPE html>
<html>
<head>
    <title>Consulta de Propuestas - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">

<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
    
    <div class="py-5">
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
                    
                    <!-- Panel de Filtros -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h5 class="card-title mb-3">
                                        <i class="bi bi-funnel"></i> Filtros de Búsqueda
                                    </h5>
                                    
                                    <form method="get" action="<%= request.getContextPath() %>/consultaPropuesta">
                                        <div class="row g-3">
                                            <!-- Búsqueda por texto -->
                                            <div class="col-md-4">
                                                <label for="busqueda" class="form-label">Buscar</label>
                                                <input type="text" class="form-control" id="busqueda" name="busqueda" 
                                                       placeholder="Título, descripción o lugar..." 
                                                       value="<%= request.getAttribute("busqueda") != null ? request.getAttribute("busqueda") : "" %>">
                                            </div>
                                            
                                            <!-- Filtro por estado -->
                                            <div class="col-md-3">
                                                <label for="estado" class="form-label">Estado</label>
                                                <select class="form-select" id="estado" name="estado">
                                                    <option value="todas" <%= "todas".equals(request.getAttribute("estadoFiltro")) ? "selected" : "" %>>Todas</option>
                                                    <option value="en_financiacion" <%= "en_financiacion".equals(request.getAttribute("estadoFiltro")) ? "selected" : "" %>>En Financiación</option>
                                                    <option value="financiadas" <%= "financiadas".equals(request.getAttribute("estadoFiltro")) ? "selected" : "" %>>Financiadas</option>
                                                    <option value="no_financiadas" <%= "no_financiadas".equals(request.getAttribute("estadoFiltro")) ? "selected" : "" %>>No Financiadas</option>
                                                    <option value="canceladas" <%= "canceladas".equals(request.getAttribute("estadoFiltro")) ? "selected" : "" %>>Canceladas</option>
                                                </select>
                                            </div>
                                            
                                            <!-- Filtro por categoría -->
                                            <div class="col-md-3">
                                                <label for="categoria" class="form-label">Categoría</label>
                                                <select class="form-select" id="categoria" name="categoria">
                                                    <option value="todas" <%= "todas".equals(request.getAttribute("categoriaFiltro")) ? "selected" : "" %>>Todas</option>
                                                    <% 
                                                    List<culturarte.logica.DTs.DTCategoria> categorias = (List<culturarte.logica.DTs.DTCategoria>) request.getAttribute("categorias");
                                                    if (categorias != null) {
                                                        for (culturarte.logica.DTs.DTCategoria categoria : categorias) {
                                                            String nombreCategoria = categoria.getNombre();
                                                            boolean selected = nombreCategoria.equals(request.getAttribute("categoriaFiltro"));
                                                    %>
                                                        <option value="<%= nombreCategoria %>" <%= selected ? "selected" : "" %>><%= nombreCategoria %></option>
                                                    <% 
                                                        }
                                                    }
                                                    %>
                                                </select>
                                            </div>
                                            
                                            <!-- Ordenamiento -->
                                            <div class="col-md-2">
                                                <label for="ordenarPor" class="form-label">Ordenar por</label>
                                                <select class="form-select" id="ordenarPor" name="ordenarPor">
                                                    <option value="" <%= request.getAttribute("ordenarPor") == null || request.getAttribute("ordenarPor").equals("") ? "selected" : "" %>>Sin ordenar</option>
                                                    <option value="alfabetico" <%= "alfabetico".equals(request.getAttribute("ordenarPor")) ? "selected" : "" %>>Alfabético</option>
                                                    <option value="fecha_creacion" <%= "fecha_creacion".equals(request.getAttribute("ordenarPor")) ? "selected" : "" %>>Fecha de creación</option>
                                                    <option value="monto_ascendente" <%= "monto_ascendente".equals(request.getAttribute("ordenarPor")) ? "selected" : "" %>>Monto (menor a mayor)</option>
                                                    <option value="monto_descendente" <%= "monto_descendente".equals(request.getAttribute("ordenarPor")) ? "selected" : "" %>>Monto (mayor a menor)</option>
                                                </select>
                                            </div>
                                        </div>
                                        
                                        <div class="row mt-3">
                                            <div class="col-12">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="bi bi-search"></i> Buscar
                                                </button>
                                                <a href="<%= request.getContextPath() %>/consultaPropuesta" class="btn btn-outline-secondary">
                                                    <i class="bi bi-arrow-clockwise"></i> Limpiar Filtros
                                                </a>
                                            </div>
                                        </div>
                                    </form>
                                    
                                    <!-- Información de resultados -->
                                    <% if (request.getAttribute("totalResultados") != null) { %>
                                        <div class="mt-3">
                                            <small class="text-muted">
                                                <i class="bi bi-info-circle"></i> 
                                                Mostrando <%= request.getAttribute("totalResultados") %> resultado(s)
                                                <% if (request.getAttribute("busqueda") != null && !request.getAttribute("busqueda").toString().trim().isEmpty()) { %>
                                                    para "<%= request.getAttribute("busqueda") %>"
                                                <% } %>
                                            </small>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    
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
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>