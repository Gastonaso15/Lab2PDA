<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cierre de Sesión - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container d-flex justify-content-center py-5">
    <div class="card shadow-sm p-4" style="width: 450px;">
        <h3 class="text-center mb-3">Cierre de Sesión</h3>

        <%--
        *** ESTE CÓDIGO SE HA ELIMINADO ***
        <%
            String mensaje = (String) request.getAttribute("mensaje");
            if (mensaje == null || mensaje.isEmpty()) {
                mensaje = "Has cerrado sesión correctamente.";
            }
        %>
        --%>

        <div class="alert alert-success text-center" role="alert">
            Has cerrado sesión correctamente.
        </div>

        <div class="d-grid gap-2 mt-3">
            <a href="<%= request.getContextPath() %>/principal.jsp" class="btn btn-primary">
                Volver al Inicio
            </a>
            <a href="<%= request.getContextPath() %>/inicioDeSesion.jsp" class="btn btn-outline-secondary">
                Iniciar Sesión
            </a>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>