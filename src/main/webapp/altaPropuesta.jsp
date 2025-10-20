<%@ page import="culturarte.logica.DTs.DTPropuesta" %>
<%@ page import="java.util.List" %>
<%@ page import="culturarte.logica.DTs.DTCategoria" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html>
<head>
    <title>Alta de Propuesta</title>
    <meta charset="utf-8"/>
</head>
<body>

<%-- Comentario #1: MIRA BRO; ACA LO RESIVO, fijate en ese request.getAttribute, viste que se llama "categorias" tambien
 tremenda casualidad no?...o quizas no sea casualidad...--%>
<% List<DTCategoria> categorias = (List<DTCategoria>) request.getAttribute("categorias");%>

<% if (request.getAttribute("error") != null) { %>
<div style="color:#b00020; margin-bottom:12px;"><%= request.getAttribute("error") %></div>
<% } %>

<form method="post" action="<%=request.getContextPath()%>/altaPropuesta" enctype="multipart/form-data">
    <h1>Alta de Propuesta</h1>

    <fieldset class="row">
        <div>
            <label>Categoría</label>
            <select name="categoria" required>
                <option value="" disabled selected>Seleccionar categoría</option>
                <% if (categorias != null) {
                    for (DTCategoria cat : categorias) { %>
                <option value="<%=cat.getNombre()%>"><%=cat.getNombre()%></option>
                <%   }
                } %>
            </select>
        </div>
        <div>
            <label>Título</label>
            <input name="titulo" maxlength="120" required/>
        </div>
    </fieldset>

    <fieldset>
        <label>Descripción</label>
        <textarea name="descripcion" rows="4" required></textarea>
    </fieldset>

    <fieldset class="row">
        <div>
            <label>Lugar</label>
            <input name="lugar" required/>
        </div>
        <div>
            <label>Fecha (AAAA-MM-DD)</label>
            <input type="date" name="fecha" required/>
        </div>
    </fieldset>

    <fieldset class="row">
        <div>
            <label>Precio de entrada</label>
            <input type="number" name="precioEntrada" min="1" step="0.01" required/>
        </div>
        <div>
            <label>Monto necesario</label>
            <input type="number" name="montoNecesario" min="1" step="0.01" required/>
        </div>
    </fieldset>

    <fieldset>
        <label>Tipos de retorno</label>
        <div class="checks">
            <label><input type="checkbox" name="retornos" value="ENTRADAS_GRATIS"> Entradas</label>
            <label><input type="checkbox" name="retornos" value="PORCENTAJE_GANANCIAS"> Porcentaje</label>
        </div>

        <div class="mb-3">
            <label class="form-label">Imagen (opcional)</label>
            <input type="file" name="imagen" class="form-control" accept="image/*">
        </div>

        <div class="actions">
            <a href="<%=request.getContextPath()%>/" class="btn">Volver al inicio</a>
            <button type="submit">Crear propuesta</button>
        </div>
    </fieldset>
</form>
</body>
</html>