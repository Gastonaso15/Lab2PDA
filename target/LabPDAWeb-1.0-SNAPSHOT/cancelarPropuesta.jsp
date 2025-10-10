<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.logica.DTs.DTPropuesta" %>
<%@ page import="java.util.List" %>
<%
    // Verificar sesión activa
    String usuario = (String) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Obtener lista de propuestas
    List<DTPropuesta> propuestas = (List<DTPropuesta>) request.getAttribute("propuestas");
    String mensaje = (String) request.getAttribute("mensaje");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cancelar Propuesta</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background-color: #f4f4f4; }
        .mensaje { color: green; margin-bottom: 20px; }
        .error { color: red; margin-bottom: 20px; }
        button { padding: 6px 12px; cursor: pointer; }
    </style>
</head>
<body>
    <h2>Propuestas Financiadas de <%= usuario %></h2>

    <% if (mensaje != null) { %>
        <p class="<%= mensaje.contains("correctamente") ? "mensaje" : "error" %>"><%= mensaje %></p>
    <% } %>

    <% if (propuestas != null && !propuestas.isEmpty()) { %>
        <table>
            <thead>
                <tr>
                    <th>Título</th>
                    <th>Descripción</th>
                    <th>Lugar</th>
                    <th>Fecha Prevista</th>
                    <th>Precio Entrada</th>
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
                        <td><%= p.getFechaPrevista() != null ? p.getFechaPrevista() : "" %></td>
                        <td><%= p.getPrecioEntrada() != null ? p.getPrecioEntrada() : "" %></td>
                        <td><%= p.getMontoNecesario() != null ? p.getMontoNecesario() : "" %></td>
                        <td>
                            <form method="post" action="<%= request.getContextPath() %>/cancelarPropuesta">
                                <input type="hidden" name="titulo" value="<%= p.getTitulo() %>"/>
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
        <p>No tienes propuestas financiadas actualmente.</p>
    <% } %>

    <p><a href="<%= request.getContextPath() %>/inicio.jsp">Volver al inicio</a></p>
    <p><a href="<%= request.getContextPath() %>/cierreSesion">Cerrar sesión</a></p>
</body>
</html>
