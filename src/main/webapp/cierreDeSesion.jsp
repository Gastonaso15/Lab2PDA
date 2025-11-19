<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cierre de Sesión - Culturarte</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>

<body class="bg-light">
<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
</div>

<div class="container py-5 d-flex justify-content-center">
    <div class="card shadow-sm p-4 w-100" style="max-width: 450px;">

        <h3 class="text-center mb-3">Cierre de Sesión</h3>

        <div class="alert alert-success text-center" role="alert">
            Has cerrado sesión correctamente.
        </div>

        <div class="d-grid gap-2 mt-3">
            <a href="<%= request.getContextPath() %>/principal" class="btn btn-primary">
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
