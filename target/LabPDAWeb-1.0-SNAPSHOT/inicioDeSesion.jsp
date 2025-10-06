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
