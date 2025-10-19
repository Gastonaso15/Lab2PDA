<%@ page import="culturarte.logica.DTs.DTPropuesta" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Extender Financiación</title>
</head>
<body>
<%-- uso este objeto para ver la sesion del usuario activo que tipo de usuario es --%>

<%
    List<DTPropuesta> propuestas = (List<DTPropuesta>) request.getAttribute("propuestas");
%>

<form method="post" action="<%=request.getContextPath()%>/extenderFinanciacion">
    <h1>Extender Financiación</h1>

    <fieldset class="row">
        <div>
            <label>Propuestas</label>
            <select name="propuestas" required>
                <option value="" disabled selected>Seleccionar propuesta</option>
                <%
                    if (propuestas != null) {
                        for (DTPropuesta prop : propuestas) {
                %>
                <%--La opcion que elige el usuario es lo que mando en value--%>
                <option value="<%=prop.getTitulo()%>"> <%=prop.getTitulo()%></option>
                <%
                    }
                } else {
                %>
                <option disabled>No hay propuestas disponibles</option>
                <% } %>
            </select>
        </div>
    </fieldset>
    <button type="submit">Extender financiación</button>

</form>
<button type="button"
        onclick="location.href='${pageContext.request.contextPath}/principal'">Volver al inicio
</button>

</body>
</html>
