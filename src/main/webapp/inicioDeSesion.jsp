<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head><title>Login Culturarte</title></head>
<body>
<h2>Iniciar sesión</h2>

<form method="post" action="${pageContext.request.contextPath}/inicioDeSesion">
    <label>Usuario:</label><br/>
    <input type="text" name="usuario"><br/><br/>

    <label>Contraseña:</label><br/>
    <input type="password" name="password"><br/><br/>

    <input type="submit" value="Entrar">
</form>

<c:if test="${not empty error}">
    <p style="color:red">${error}</p>
</c:if>

</body>
</html>
