<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Confirmar Colaboración - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">
<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
    
    <div class="py-5">
    <div class="card shadow-sm p-4 mx-auto" style="max-width: 600px;">
        <h2 class="text-center mb-3">Colaborar en: ${propuesta.titulo}</h2>

        <p><strong>Descripción:</strong> ${propuesta.descripcion}</p>
        <p><strong>Estado actual:</strong> ${propuesta.estadoActual}</p>
        <p><strong>Proponente:</strong> ${propuesta.proponente}</p>

        <form action="${pageContext.request.contextPath}/registrarColaboracionAPropuesta" method="post" class="mt-4">
            <input type="hidden" name="accion" value="confirmar"/>
            <input type="hidden" name="titulo" value="${propuesta.titulo}"/>

            <div class="mb-3">
                <label for="tipoRetorno" class="form-label">Tipo de Retorno:</label>
                <select class="form-select" id="tipoRetorno" name="tipoRetorno" required>
                    <c:forEach var="t" items="${tiposRetorno}">
                        <option value="${t.nombre}">${t.nombre} - Mínimo: $${t.montoMinimo}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="mb-3">
                <label for="monto" class="form-label">Monto:</label>
                <input type="number" id="monto" name="monto" step="0.01" class="form-control" required/>
            </div>

            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-success">Confirmar Colaboración</button>
            </div>
        </form>

        <form action="${pageContext.request.contextPath}/registrarColaboracionAPropuesta" method="get" class="mt-3">
            <button type="submit" class="btn btn-outline-secondary w-100">Cancelar</button>
        </form>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mt-3 text-center">${error}</div>
        </c:if>

        <c:if test="${not empty mensaje}">
            <div class="alert alert-success mt-3 text-center">${mensaje}</div>
        </c:if>
    </div>
    </div>
</div>
</body>
</html>
