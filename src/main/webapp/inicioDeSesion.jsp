<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Iniciar Sesion - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">
    <jsp:include page="cabezalComun.jsp"/>

<div class="container d-flex justify-content-center align-items-center" style="height: 100vh;">
    <div class="card shadow-sm p-4" style="width: 350px;">
        <h3 class="text-center mb-3">Iniciar sesión</h3>

        <form method="post" action="<%= request.getContextPath() %>/inicioDeSesion">
            <div class="mb-3">
                <label class="form-label">Usuario</label>
                <input type="text" name="usuario" class="form-control" placeholder="Ingrese su nickname o correo">
            </div>

            <div class="mb-3">
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" class="form-control" placeholder="Ingrese su contraseña">
            </div>

            <button type="submit" class="btn btn-primary w-100">Entrar</button>
        </form>

        <%String error = (String) request.getAttribute("error");
         if (error != null && !error.isEmpty()) {%>
            <div class="alert alert-danger mt-3" role="alert">
                <%=error%>
            </div>
        <%}%>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
