<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Inicio de Sesion</title></head>
<body>
<h2>Iniciar sesión</h2>

<form method="post" action="${pageContext.request.contextPath}/inicioDeSesion">
    <label>Usuario:</label><br/>
    <input type="text" name="usuario"><br/><br/>

    <label>Contraseña:</label><br/>
    <input type="password" name="password"><br/><br/>

    <input type="submit" value="Entrar">
</form>

<% if (request.getAttribute("error") != null) { %>
    <p style="color:red"><%= request.getAttribute("error") %></p>
<% } %>

</body>
</html>

<!--

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container d-flex justify-content-center align-items-center" style="height: 100vh;">
    <div class="card shadow-sm p-4" style="width: 350px;">
        <h3 class="text-center mb-3">Iniciar sesión</h3>

        <form method="post" action="${pageContext.request.contextPath}/inicioDeSesion">
            <div class="mb-3">
                <label class="form-label">Usuario</label>
                <input type="text" name="usuario" class="form-control" placeholder="Ingrese su usuario">
            </div>

            <div class="mb-3">
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" class="form-control" placeholder="Ingrese su contraseña">
            </div>

            <button type="submit" class="btn btn-primary w-100">Entrar</button>
        </form>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mt-3" role="alert">
                ${error}
            </div>
        </c:if>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
-->
