<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Registrar Colaboración a Propuesta</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; }
        label { display: block; margin-top: 10px; }
        input, select { margin-top: 5px; }
        h2 { color: #333; }
        .mensaje { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            padding-top: 150px;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
        }
        .modal-content {
            background-color: #fff;
            margin: auto;
            padding: 20px;
            border-radius: 10px;
            width: 300px;
            text-align: center;
        }
        .modal-content button {
            margin: 5px;
        }
    </style>
</head>
<body>

<h2>Registrar Colaboración a una Propuesta</h2>

<!-- Paso 1: Seleccionar propuesta -->
<form action="registrarColaboracion" method="post">
    <input type="hidden" name="accion" value="seleccionar"/>

    <label for="titulo">Seleccionar Propuesta:</label>
    <select name="titulo" required>
        <c:forEach var="p" items="${propuestas}">
            <option value="${p.titulo}"
                    <c:if test="${propuestaSeleccionada != null && propuestaSeleccionada.titulo == p.titulo}">selected</c:if>>
                ${p.titulo} - ${p.proponente}
            </option>
        </c:forEach>
    </select>

    <button type="submit">Ver Detalles</button>
</form>

<hr>

<!-- Paso 2: Mostrar detalles -->
<c:if test="${not empty propuestaSeleccionada}">
    <h3>Detalles de la Propuesta Seleccionada</h3>
    <p><strong>Título:</strong> ${propuestaSeleccionada.titulo}</p>
    <p><strong>Descripción:</strong> ${propuestaSeleccionada.descripcion}</p>
    <p><strong>Precio de entrada:</strong> $${propuestaSeleccionada.precioEntrada}</p>
    <p><strong>Monto requerido:</strong> $${propuestaSeleccionada.montoRequerido}</p>

    <!-- Paso 3: Registrar colaboración -->
    <form action="registrarColaboracion" method="post">
        <input type="hidden" name="accion" value="confirmar"/>
        <input type="hidden" name="titulo" value="${propuestaSeleccionada.titulo}"/>

        <label for="monto">Monto a Colaborar:</label>
        <input type="number" name="monto" min="1" required/>

        <label for="tipoRetorno">Tipo de Retorno:</label>
        <select name="tipoRetorno" required>
            <option value="ENTRADA">Entrada</option>
            <option value="PORCENTAJE_GANANCIA">Porcentaje de Ganancia</option>
            <option value="AMBOS">Ambos</option>
        </select>

        <br><br>
        <button type="submit">Confirmar</button>
        <button type="button" onclick="abrirModal()">Cancelar</button>
    </form>
</c:if>

<!-- Modal de cancelación -->
<div id="modalCancelar" class="modal">
    <div class="modal-content">
        <p>¿Seguro que deseas cancelar la colaboración?</p>
        <form action="registrarColaboracion" method="post">
            <input type="hidden" name="accion" value="cancelar"/>
            <button type="submit">Sí</button>
            <button type="button" onclick="cerrarModal()">No</button>
        </form>
    </div>
</div>

<!-- Mensajes -->
<c:if test="${not empty mensaje}">
    <p class="mensaje">${mensaje}</p>
</c:if>

<c:if test="${not empty error}">
    <p class="error">${error}</p>
</c:if>

<script>
    function abrirModal() {
        document.getElementById("modalCancelar").style.display = "block";
    }
    function cerrarModal() {
        document.getElementById("modalCancelar").style.display = "none";
    }
</script>

</body>
</html>
