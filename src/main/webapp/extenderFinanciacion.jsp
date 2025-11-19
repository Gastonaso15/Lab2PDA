<%@ page import="culturarte.servicios.cliente.propuestas.DtPropuesta" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Extender Financiación</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<%
    List<DtPropuesta> propuestas = (List<DtPropuesta>) request.getAttribute("propuestas");
%>

<div class="container py-4">
    <h1 class="h3 mb-4">Extender Financiación</h1>

    <%-- Si el servlet mandó un error, lo muestro --%>
    <%
        Object err = request.getAttribute("error");
        if (err != null) {
    %>
    <div class="alert alert-danger"><%= err %></div>
    <% } %>

    <form method="post" action="<%=request.getContextPath()%>/extenderFinanciacion" class="row g-3">
        <fieldset class="col-12 col-md-6">
            <div class="mb-2">
                <label class="form-label">Propuestas</label>
                <select name="propuestas" class="form-select" required>
                    <option value="" disabled selected>Seleccionar propuesta</option>
                    <%
                        if (propuestas != null) {
                            for (DtPropuesta prop : propuestas) {
                    %>
                    <%--La opcion que elige el usuario es lo que mando en value--%>
                    <option value="<%=prop.getTitulo()%>"><%=prop.getTitulo()%></option>
                    <%
                        }
                    } else {
                    %>
                    <option disabled>No hay propuestas disponibles</option>
                    <% } %>
                </select>
            </div>
        </fieldset>

        <div class="col-12">
            <button type="submit" class="btn btn-primary">Extender financiación</button>
            <button type="button" class="btn btn-outline-secondary ms-2"
                    onclick="location.href='${pageContext.request.contextPath}/principal'">
                Volver al inicio
            </button>
        </div>
    </form>
</div>

</body>
</html>