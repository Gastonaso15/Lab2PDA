<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registrar Colaboración - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="card shadow-sm p-4 mx-auto" style="max-width: 600px;">
        <h2 class="text-center mb-4">Seleccionar Propuesta</h2>

        <form action="${pageContext.request.contextPath}/registrarColaboracionAPropuesta" method="get">
            <input type="hidden" name="modo" value="detalle"/>

            <div class="mb-3">
                <label for="titulo" class="form-label">Propuesta:</label>
                <select class="form-select" name="titulo" id="titulo" required>
                    <c:forEach var="p" items="${propuestas}">
                        <option value="${p.titulo}">${p.titulo} - ${p.proponente}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="d-grid">
                <button type="submit" class="btn btn-primary">Ver Detalles</button>
            </div>
        </form>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mt-3 text-center">${error}</div>
        </c:if>

        <c:if test="${not empty mensaje}">
            <div class="alert alert-success mt-3 text-center">${mensaje}</div>
        </c:if>
    </div>
</div>
</body>
</html>