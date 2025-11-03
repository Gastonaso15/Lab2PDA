<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>Iniciar Sesión - Culturarte</title>

    <!--para móvil -->
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">

<!-- Cabecera -->

<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
</div>

<!-- Contenido centrado y fluido -->
<main class="container d-flex justify-content-center py-3 pt-md-5">
    <div class="row justify-content-center w-100">
        <!-- Columna responsiva: ocupa to do móvil y se achica en pantallas grandes -->
        <div class="col-12 col-sm-10 col-md-7 col-lg-5 col-xl-4">
            <div class="card shadow-sm p-4 p-md-5">
                <h3 class="text-center mb-4">Iniciar sesión</h3>

                <form method="post" action="<%= request.getContextPath() %>/inicioDeSesion" novalidate>
                    <div class="mb-3">
                        <label class="form-label" for="usuario">Usuario</label>
                        <input id="usuario" name="usuario" type="text"
                               class="form-control"
                               placeholder="Nickname o correo"
                               autocomplete="username" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="password">Contraseña</label>
                        <input id="password" name="password" type="password"
                               class="form-control"
                               placeholder="Ingrese su contraseña"
                               autocomplete="current-password" required>
                    </div>

                    <button type="submit" class="btn btn-primary w-100">Entrar</button>
                </form>

                <% String error = (String) request.getAttribute("error");
                    if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger mt-3" role="alert">
                    <%= error %>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
