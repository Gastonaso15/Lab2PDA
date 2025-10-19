<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="culturarte.logica.DTs.*" %>
<!DOCTYPE html>
<html>
<head><title>Perfil de Usuario</title></head>
<body>
<% String ctx = request.getContextPath(); %>
<h1>Consulta de Perfil de Usuario</h1>

<%
    // Paso 1: listado de nicks (primer pantalla)
    List<String> nicknames = (List<String>) request.getAttribute("nicknames");
    DTUsuario usuario = null;
    boolean esProponente = false;
    Boolean esPropio = null;
    boolean esColaborador = false;
    if (nicknames != null) {
%>
<form method="get" action="<%=ctx%>/consultaPerfilUsuario">
    <label>Elegí un usuario:</label>
    <select name="nick">
        <% for (String n : nicknames) { %>
        <option value="<%=n%>"><%=n%></option>
        <% } %>
    </select>
    <button type="submit">Ver perfil</button>
</form>

<%
} else {
    // Paso 2: vista de perfil
    usuario = (DTUsuario) request.getAttribute("usuarioConsultado");
    esPropio = (Boolean) request.getAttribute("esPropio");
    esProponente = request.getAttribute("esProponente") != null && (Boolean) request.getAttribute("esProponente");
    esColaborador = request.getAttribute("esColaborador") != null && (Boolean) request.getAttribute("esColaborador");

    List<String> siguiendoProponentes = (List<String>) request.getAttribute("siguiendoProponentes");
    List<String> siguiendoColaboradores = (List<String>) request.getAttribute("siguiendoColaboradores");
    List<String> followersProponentes = (List<String>) request.getAttribute("followersProponentes");
    List<String> followersColaboradores = (List<String>) request.getAttribute("followersColaboradores");

    List<DTPropuesta> favoritas = (List<DTPropuesta>) request.getAttribute("favoritas");
    List<DTPropuesta> publicadasNoIngresada = (List<DTPropuesta>) request.getAttribute("publicadasNoIngresada");
    List<DTPropuesta> colaboradas = (List<DTPropuesta>) request.getAttribute("colaboradas");
    List<DTPropuesta> creadasIngresadas = (List<DTPropuesta>) request.getAttribute("creadasIngresadas");
    List<DTColaboracion> misColaboraciones = (List<DTColaboracion>) request.getAttribute("misColaboraciones");
%>

<%--Caso: Usuario Ve su propio Perfil --%>
<h2>Perfil de <%=(usuario != null ? usuario.getNickname() : request.getParameter("nick"))%></h2>
<div>
    <% if (usuario != null && usuario.getImagen() != null && !usuario.getImagen().isBlank()) { %>
    <img alt="avatar" src="<%=usuario.getImagen()%>" style="max-height:120px"/>
    <br/>
    <% } %>
    <div>
        <b>Tipo:</b> <%=esProponente ? "Proponente" : (esColaborador ? "Colaborador" : "Usuario")%><br/>
        <% if (usuario != null) { %>
        <b>Nombre:</b> <%=usuario.getNombre()%> <%=usuario.getApellido()%><br/>
        <b>Correo:</b> <%=usuario.getCorreo()%><br/>
        <% } %>
        <% if (esPropio != null && esPropio) { %>
        <i>Estás viendo tu propio perfil.</i><br/>
        <% } %>
    </div>
</div>

<hr/>

<!-- Seguidores -->
<h3>Seguidores</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Nickname</th><th>Tipo</th><th>Acciones</th></tr>
    <% boolean hayFollowers = false; %>
    <% if (followersProponentes != null) {
        for (String n : followersProponentes) {
            hayFollowers = true; %>
    <tr>
        <td><%=n%></td>
        <td>Proponente</td>
        <td><a href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
    </tr>
    <% }
    } %>
    <% if (followersColaboradores != null) {
        for (String n : followersColaboradores) {
            hayFollowers = true; %>
    <tr>
        <td><%=n%></td>
        <td>Colaborador</td>
        <td><a href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
    </tr>
    <% }
    } %>
    <% if (!hayFollowers) { %>
    <tr><td colspan="3">(sin seguidores)</td></tr>
    <% } %>
</table>

<!-- Siguiendo -->
<h3>Siguiendo</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Nickname</th><th>Tipo</th><th>Acciones</th></tr>
    <% boolean haySiguiendo = false; %>
    <% if (siguiendoProponentes != null) {
        for (String n : siguiendoProponentes) {
            haySiguiendo = true; %>
    <tr>
        <td><%=n%></td>
        <td>Proponente</td>
        <td><a href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
    </tr>
    <% }
    } %>
    <% if (siguiendoColaboradores != null) {
        for (String n : siguiendoColaboradores) {
            haySiguiendo = true; %>
    <tr>
        <td><%=n%></td>
        <td>Colaborador</td>
        <td><a href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
    </tr>
    <% }
    } %>
    <% if (!haySiguiendo) { %>
    <tr><td colspan="3">(no sigue a nadie)</td></tr>
    <% } %>
</table>

<!-- Favoritas -->
<h3>Propuestas favoritas</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Título</th><th>Acciones</th></tr>
    <% if (favoritas != null && !favoritas.isEmpty()) {
        for (DTPropuesta p : favoritas) { %>
    <tr>
        <td><%=p.getTitulo()%></td>
        <td><a href="<%=ctx%>/consultaPropuesta?titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
    </tr>
    <% }
    } else { %>
    <tr><td colspan="2">(sin favoritas)</td></tr>
    <% } %>
</table>

<!-- Publicadas (no INGRESADA) - solo si es proponente -->
<% if (esProponente) { %>
<h3>Publicadas (no INGRESADA)</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Título</th><th>Estado</th><th>Acciones</th></tr>
    <% if (publicadasNoIngresada != null && !publicadasNoIngresada.isEmpty()) {
        for (DTPropuesta p : publicadasNoIngresada) { %>
    <tr>
        <td><%=p.getTitulo()%></td>
        <td><%=p.getEstadoActual()%></td>
        <td><a href="<%=ctx%>/consultaPropuesta?titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
    </tr>
    <% }
    } else { %>
    <tr><td colspan="3">(sin propuestas publicadas fuera de INGRESADA)</td></tr>
    <% } %>
</table>
<% } %>

<!-- Colaboradas - solo si es colaborador -->
<% if (esColaborador) { %>
<h3>Propuestas colaboradas</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Título</th><th>Acciones</th></tr>
    <% if (colaboradas != null && !colaboradas.isEmpty()) {
        for (DTPropuesta p : colaboradas) { %>
    <tr>
        <td><%=p.getTitulo()%></td>
        <td><a href="<%=ctx%>/consultaPropuesta?titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
    </tr>
    <% }
    } else { %>
    <tr><td colspan="2">(sin colaboraciones)</td></tr>
    <% } %>
</table>
<% } %>

<!-- (Propio) Mis INGRESADAS - solo si es propio y proponente -->
<% if (esPropio != null && esPropio && esProponente) { %>
<h3>Mis propuestas en estado INGRESADA</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Título</th><th>Estado</th><th>Acciones</th></tr>
    <% if (creadasIngresadas != null && !creadasIngresadas.isEmpty()) {
        for (DTPropuesta p : creadasIngresadas) { %>
    <tr>
        <td><%=p.getTitulo()%></td>
        <td><%=p.getEstadoActual()%></td>
        <td><a href="<%=ctx%>/consultaPropuesta?titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
    </tr>
    <% }
    } else { %>
    <tr><td colspan="3">(sin propuestas en estado INGRESADA)</td></tr>
    <% } %>
</table>
<% } %>

<!-- (Propio) Mis colaboraciones - solo si es propio y colaborador -->
<% if (esPropio != null && esPropio && esColaborador) { %>
<h3>Mis colaboraciones</h3>
<table border="1" cellpadding="4" cellspacing="0">
    <tr><th>Propuesta</th><th>Monto</th><th>Acciones</th></tr>
    <% if (misColaboraciones != null && !misColaboraciones.isEmpty()) {
        for (DTColaboracion c : misColaboraciones) { %>
    <tr>
        <td><%=(c.getPropuesta() != null ? c.getPropuesta().getTitulo() : "(Propuesta)")%></td>
        <td><%=c.getMonto()%></td>
        <td>
            <% if (c.getPropuesta() != null) { %>
            <a href="<%=ctx%>/consultaPropuesta?titulo=<%=c.getPropuesta().getTitulo()%>">Ver detalle</a>
            <% } %>
        </td>
    </tr>
    <% }
    } else { %>
    <tr><td colspan="3">(sin colaboraciones propias)</td></tr>
    <% } %>
</table>
<% } %>

<% }  %>
<button type="button"
        onclick="location.href='${pageContext.request.contextPath}/principal'">Volver al inicio
</button>

<%--Solo muestro el boton para seguir usuario si no es visitante--%>
<div>
    <%
        DTUsuario usuarioConsultadoBtn = (DTUsuario) request.getAttribute("usuarioConsultado");
        String nickConsultadoBtn = (usuarioConsultadoBtn != null)
                ? usuarioConsultadoBtn.getNickname()
                : request.getParameter("nick");

        DTUsuario usuarioActualBtn = (DTUsuario) session.getAttribute("usuarioLogueado");
        Boolean esPropioBtn = (Boolean) request.getAttribute("esPropio");
        boolean puedeSeguir = (usuarioActualBtn != null) && Boolean.FALSE.equals(esPropioBtn);
        boolean loSigo = Boolean.TRUE.equals(request.getAttribute("loSigo"));
        if (puedeSeguir) {
    %>
    <form method="post" action="<%= ctx %>/seguimientoDeUsuario">
        <input type="hidden" name="seguido" value="<%= nickConsultadoBtn %>">
        <button type="submit"><%= loSigo ? "Dejar de seguir" : "Seguir" %></button>
    </form>
    <% } %>
</div>

</body>
</html>