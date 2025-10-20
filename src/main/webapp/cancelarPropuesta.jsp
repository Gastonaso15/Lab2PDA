<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.logica.DTs.DTPropuesta" %>
<%@ page import="java.util.List" %>
<%
    // Obtener lista de propuestas y mensaje del servlet
    List<DTPropuesta> propuestas = (List<DTPropuesta>) request.getAttribute("propuestas");
    String mensaje = (String) request.getAttribute("mensaje");
    // Obtener el nickname del usuario de la sesión para el título
    String nickname = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cancelar Propuesta</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; padding: 20px; background-color: #f9f9f9; }
        h2 { color: #333; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); background-color: #fff; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f2f2f2; color: #555; }
        .mensaje { padding: 15px; margin-bottom: 20px; border-radius: 5px; color: #155724; background-color: #d4edda; border: 1px solid #c3e6cb; }
        .error { padding: 15px; margin-bottom: 20px; border-radius: 5px; color: #721c24; background-color: #f8d7da; border: 1px solid #f5c6cb; }
        button { padding: 8px 15px; cursor: pointer; border-radius: 5px; border: none; background-color: #dc3545; color: white; font-weight: bold; }
        button:hover { background-color: #c82333; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body>
    <jsp:include page="cabezalComun.jsp"/>
    <h2>Propuestas Financiadas de <%= nickname != null ? nickname : "Usuario" %></h2>

    <% if (mensaje != null) { %>
        <p class="<%= mensaje.toLowerCase().contains("correctamente") ? "mensaje" : "error" %>"><%= mensaje %></p>
    <% } %>

    <% if (propuestas != null && !propuestas.isEmpty()) { %>
        <table>
            <thead>
                <tr>
                    <th>Título</th>
                    <th>Descripción</th>
                    <th>Lugar</th>
                    <th>Monto Necesario</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                <% for (DTPropuesta p : propuestas) { %>
                    <tr>
                        <td><%= p.getTitulo() %></td>
                        <td><%= p.getDescripcion() %></td>
                        <td><%= p.getLugar() %></td>
                        <td>$<%= String.format("%.2f", p.getMontoNecesario()) %></td>
                        <td>
                            <form method="post" action="<%= request.getContextPath() %>/cancelarPropuesta">
                                <input type="hidden" name="titulo" value="<%= p.getTitulo() %>"/>
                                <%-- No es necesario el source aquí, el servlet lo manejará por defecto --%>
                                <button type="submit" onclick="return confirm('¿Estás seguro que deseas cancelar esta propuesta?');">
                                    Cancelar
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } else { %>
        <p>No tienes propuestas en estado "Financiada" para cancelar.</p>
    <% } %>

    <p><a href="<%= request.getContextPath() %>/principal">Volver al inicio</a></p>
</body>
</html>