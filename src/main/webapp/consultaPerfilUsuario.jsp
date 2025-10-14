<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.logica.DTs.DTUsuario" %>
<!DOCTYPE html>
<html>
<head>
    <title>Perfil de Usuario - Prueba</title>
</head>
<body>
<%
    DTUsuario usuario = (DTUsuario) request.getAttribute("usuarioConsultado");
    if (usuario != null) {
%>
    <h1>Perfil de <%= usuario.getNickname() %></h1>
    <form action="<%= request.getContextPath() %>/seguimientoDeUsuario" method="post">
        <input type="hidden" name="seguido" value="<%= usuario.getNickname() %>">
        <button type="submit">Seguir / Dejar de Seguir</button>
    </form>
<%
    } else {
%>
    <p>No hay usuario para mostrar</p>
<%
    }
%>
</body>
</html>
