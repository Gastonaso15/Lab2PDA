<!--Puedes modificar todo de este archivo, solo lo cree como algo temporal para hacer pruebas. Solo intenta mantener la logica del boton de seguir/dejar de seguir usuario -->

<%@ page import="culturarte.logica.DTs.DTUsuario, culturarte.logica.Fabrica, culturarte.logica.controladores.IControladorUsuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- Necesito que implementes esta parte del codigo (conseguit el usuarioActual y el usuarioConsultado). Puedes modificarlo como gustes, pero que de alguna forma consiga el boolean -->
<%boolean yaSigue = ICU.UsuarioUnoYaSigueUsuarioDos(usuarioActual.getNickname(), usuarioConsultado.getNickname();%>

<!DOCTYPE html>
<html>
<head>
    <title>Perfil</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<!-- Boton de Seguir/Dejar de seguir Usuario -->
<form method="post" action="<%= request.getContextPath() %>/seguimientoDeUsuario">
    <input type="hidden" name="nickSeguido" value="<%= usuario.getNickname() %>">
        <button type="submit" class="btn btn-primary w-100"><%= yaSigue ? "Dejar de seguir" : "Seguir" %>
        </button>
</form>

</body>
</html>