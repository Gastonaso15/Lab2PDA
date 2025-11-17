<%@ page import="culturarte.servicios.cliente.propuestas.DtTipoRetorno, culturarte.servicios.cliente.propuestas.DtPropuesta, java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Registrar Colaboración a Propuesta</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>

    <style>
        body {
            background-color: #f8f9fa;
            padding-top: 2rem;
            padding-bottom: 2rem;
        }
    </style>
</head>
<body>

<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
    <div class="row justify-content-center">
        <div class="col-md-8">

            <div class="text-center mb-4">
                <h2><i class="bi bi-cash-coin"></i> Registrar Colaboración</h2>
                <p class="lead">Apoya una propuesta cultural y sé parte del proyecto.</p>
            </div>

            <c:if test="${not empty mensaje}">
                <div class="alert alert-success" role="alert">${mensaje}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">${error}</div>
            </c:if>

            <div class="card shadow-sm">
                <div class="card-header">
                    <h5 class="mb-0">Paso 1: Selecciona una Propuesta</h5>
                </div>
                <div class="card-body">
                    <form action="registrarColaboracion" method="post">
                        <input type="hidden" name="accion" value="seleccionar"/>
                        <div class="input-group">
                            <select id="selectPropuesta" name="titulo" class="form-select" required
                                    onchange="this.form.submit()"> <%-- CAMBIO: Añadido para auto-submit --%>
                                <option value="" disabled ${empty propuestaSeleccionada ? 'selected' : ''}>-- Elige una propuesta para ver sus detalles --</option>
                                <c:forEach var="p" items="${propuestas}">
                                    <option value="${p.titulo}" <c:if test="${not empty propuestaSeleccionada && propuestaSeleccionada.titulo eq p.titulo}">selected</c:if>>
                                        ${p.titulo} (por ${p.DTProponente.nickname})
                                    </option>
                                </c:forEach>
                            </select>
                            <button type="button" class="btn btn-primary d-none d-md-block"
                                    onclick="if(document.getElementById('selectPropuesta').value){window.location.href='${pageContext.request.contextPath}/consultaPropuesta?accion=detalle&titulo=' + encodeURIComponent(document.getElementById('selectPropuesta').value);}">
                                Ver Detalles
                            </button>
                        </div>
                        <div class="form-text mt-2">
                            Al cambiar la selección, los detalles se cargarán automáticamente.
                        </div>
                    </form>
                </div>
            </div>

            <c:if test="${not empty propuestaSeleccionada}">
                <div class="card shadow-sm mt-4">
                    <div class="card-header">
                        <h5 class="mb-0">Paso 2: Detalles de "${propuestaSeleccionada.titulo}"</h5>
                    </div>
                    <div class="card-body">
                        <p><strong>Descripción:</strong> ${propuestaSeleccionada.descripcion}</p>
                        <ul class="list-group list-group-flush mb-3">
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                Precio de entrada:
                                <span class="badge bg-info rounded-pill">$${String.format("%.2f", propuestaSeleccionada.precioEntrada)}</span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                Monto requerido:
                                <span class="badge bg-success rounded-pill">$${String.format("%.2f", propuestaSeleccionada.montoNecesario)}</span>
                            </li>
                        </ul>

                        <hr>

                        <h5 class="mt-3">Paso 3: Realiza tu Colaboración</h5>
                        <form action="registrarColaboracion" method="post">
                            <input type="hidden" name="accion" value="confirmar"/>
                            <input type="hidden" name="titulo" value="${propuestaSeleccionada.titulo}"/>

                            <div class="mb-3">
                                <label for="monto" class="form-label">Monto a Colaborar ($):</label>
                                <input type="number" name="monto" id="monto" class="form-control" min="1" required/>
                            </div>
<%
    DtPropuesta propuestaSeleccionada = (DtPropuesta) request.getAttribute("propuestaSeleccionada");
    if (propuestaSeleccionada != null) {
        List<DtTipoRetorno> listaTipoRet = propuestaSeleccionada.getTiposRetorno();
        String tipoRetornoString = "";
        if (listaTipoRet != null) {
            for (DtTipoRetorno i : listaTipoRet){
                if (i != null) {
                    tipoRetornoString = tipoRetornoString + i.value();
                }
            }
        }
    }
%>
                            <div class="mb-3">
                                <label for="tipoRetorno" class="form-label">Tipo de Retorno:</label>
                                <select name="tipoRetorno" id="tipoRetorno" class="form-select" required>
                                    <option value="ENTRADAS_GRATIS">Entradas Gratis</option>
                                    <option value="PORCENTAJE_GANANCIAS">Porcentaje de Ganancia</option>
                                    <option value="AMBOS">Ambos</option>
                                </select>
                            </div>

                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                <button type="button" class="btn btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#modalCancelar">
                                    Cancelar
                                </button>
                                <button type="submit" class="btn btn-success">
                                    <i class="bi bi-check-circle"></i> Confirmar Colaboración
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>

        </div>
    </div>
</div>

<div class="modal fade" id="modalCancelar" tabindex="-1" aria-labelledby="modalCancelarLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalCancelarLabel">Confirmar Cancelación</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                ¿Seguro que deseas cancelar la colaboración y volver a la página principal?
            </div>
            <div class="modal-footer">
                <form action="registrarColaboracion" method="post" class="d-inline">
                    <input type="hidden" name="accion" value="cancelar"/>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No</button>
                    <button type="submit" class="btn btn-danger">Sí, cancelar</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>