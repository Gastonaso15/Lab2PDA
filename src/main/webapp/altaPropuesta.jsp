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

<% List<DTCategoria> categorias = (List<DTCategoria>) request.getAttribute("categorias");%>

<form method="post" action="<%=request.getContextPath()%>/altaPropuesta">
    <h1>Alta de Propuesta</h1>

    <fieldset class="row">
        <div>
            <label>Categoría</label>
            <select name="categoria" required>
                <option value="" disabled selected>Seleccionar categoría</option>
                <% for (DTCategoria cat : categorias) { %>
                <option value="<%=cat.getNombre()%>"><%=cat.getNombre()%></option>
                <% } %>
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
    </fieldset>

    <fieldset>
        <label>Imagen (opcional)</label>
        <input name="imagen"/>
    </fieldset>

    <div class="actions">
        <a href="<%=request.getContextPath()%>/" class="btn">Cancelar</a>
        <button type="submit">Crear propuesta</button>
    </div>
</form>

</body>
</html>