<%@ page import="culturarte.servicios.cliente.propuestas.DtPropuesta" %>
<%@ page import="java.util.List" %>
<%@ page import="culturarte.servicios.cliente.propuestas.DtCategoria" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <title>Alta de Propuesta</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">

<%-- Comentario #1: MIRA BRO; ACA LO RESIVO, fijate en ese request.getAttribute, viste que se llama "categorias" tambien
 tremenda casualidad no?...o quizas no sea casualidad...--%>
<% List<DtCategoria> categorias = (List<DtCategoria>) request.getAttribute("categororias"); %>
<% categorias = (categorias == null) ? (List<DtCategoria>) request.getAttribute("categorias") : categorias; %>

<div class="container py-4">
    <jsp:include page="cabezalComun.jsp"/>
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h1 class="h3 mb-4">Alta de Propuesta</h1>

                    <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= request.getAttribute("error") %>
                    </div>
                    <% } %>

                    <form method="post" action="<%=request.getContextPath()%>/altaPropuesta" enctype="multipart/form-data" class="needs-validation" novalidate>
                        <div class="row g-3">

                            <!-- Categoría / Título -->
                            <div class="col-12 col-md-6">
                                <label class="form-label">Categoría</label>
                                <select name="categoria" class="form-select" required>
                                    <option value="" disabled <%= request.getParameter("categoria") == null ? "selected" : "" %>>Seleccionar categoría</option>
                                    <% if (categorias != null) {
                                        for (DtCategoria cat : categorias) {
                                            String selected = cat.getNombre().equals(request.getParameter("categoria")) ? "selected" : "";
                                    %>
                                    <option value="<%=cat.getNombre()%>" <%=selected%>><%=cat.getNombre()%></option>
                                    <%   }
                                    } %>
                                </select>
                                <div class="invalid-feedback">Elegí una categoría.</div>
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label">Título</label>
                                <input name="titulo" maxlength="120" required class="form-control"
                                       placeholder="Nombre de la propuesta"
                                       value="<%= request.getParameter("titulo") != null ? request.getParameter("titulo") : "" %>"/>
                                <div class="invalid-feedback">Ingresá un título.</div>
                            </div>

                            <!-- Descripción -->
                            <div class="col-12">
                                <label class="form-label">Descripción</label>
                                <textarea name="descripcion" rows="4" required class="form-control"
                                          placeholder="Contanos de qué se trata..."><%= request.getParameter("descripcion") != null ? request.getParameter("descripcion") : "" %></textarea>
                                <div class="invalid-feedback">Ingresá una descripción.</div>
                            </div>

                            <!-- Lugar / Fecha -->
                            <div class="col-12 col-md-6">
                                <label class="form-label">Lugar</label>
                                <input name="lugar" required class="form-control" placeholder="Ej: Teatro Unión"
                                       value="<%= request.getParameter("lugar") != null ? request.getParameter("lugar") : "" %>"/>
                                <div class="invalid-feedback">Ingresá un lugar.</div>
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label">Fecha (AAAA-MM-DD)</label>
                                <input type="date" name="fecha" required class="form-control"
                                       value="<%= request.getParameter("fecha") != null ? request.getParameter("fecha") : "" %>"/>
                                <div class="invalid-feedback">Seleccioná una fecha.</div>
                            </div>

                            <!-- Precios -->
                            <div class="col-12 col-md-6">
                                <label class="form-label">Precio de entrada</label>
                                <input type="number" name="precioEntrada" min="1" step="0.01" required class="form-control"
                                       placeholder="0.00"
                                       value="<%= request.getParameter("precioEntrada") != null ? request.getParameter("precioEntrada") : "" %>"/>
                                <div class="invalid-feedback">Ingresá un precio válido.</div>
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label">Monto necesario</label>
                                <input type="number" name="montoNecesario" min="1" step="0.01" required class="form-control"
                                       placeholder="0.00"
                                       value="<%= request.getParameter("montoNecesario") != null ? request.getParameter("montoNecesario") : "" %>"/>
                                <div class="invalid-feedback">Ingresá un monto válido.</div>
                            </div>

                            <!-- Retornos -->
                            <div class="col-12">
                                <label class="form-label d-block">Tipos de retorno</label>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" id="ret1" type="checkbox" name="retornos" value="ENTRADAS_GRATIS"
                                           <%= request.getParameterValues("retornos") != null && java.util.Arrays.asList(request.getParameterValues("retornos")).contains("ENTRADAS_GRATIS") ? "checked" : "" %>>
                                    <label class="form-check-label" for="ret1">Entradas</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" id="ret2" type="checkbox" name="retornos" value="PORCENTAJE_GANANCIAS"
                                           <%= request.getParameterValues("retornos") != null && java.util.Arrays.asList(request.getParameterValues("retornos")).contains("PORCENTAJE_GANANCIAS") ? "checked" : "" %>>
                                    <label class="form-check-label" for="ret2">Porcentaje</label>
                                </div>
                            </div>

                            <!-- Imagen -->
                            <div class="col-12">
                                <label class="form-label">Imagen (opcional)</label>
                                <input type="file" name="imagen" class="form-control" accept="image/*">
                            </div>

                            <!-- Acciones -->
                            <div class="col-12 d-flex gap-2 mt-2">
                                <a href="<%=request.getContextPath()%>/" class="btn btn-outline-secondary">Volver al inicio</a>
                                <button type="submit" class="btn btn-primary">Crear propuesta</button>
                            </div>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS (opcional, para validación visual) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Validación Bootstrap-> Simplemente recumpero los required que puse con html y mando mensajes con bootstrap bonitos
    (function () {
        'use strict';
        const forms = document.querySelectorAll('.needs-validation');
        Array.prototype.slice.call(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    })();
</script>
</body>
</html>