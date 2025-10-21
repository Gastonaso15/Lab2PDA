<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="culturarte.logica.DTs.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Perfil de Usuario</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap 5 (CDN) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<% String ctx = request.getContextPath(); %>

<div class="container py-4">
    <h1 class="h3 mb-4">Consulta de Perfil de Usuario</h1>

    <%-- Mensaje de error si llegó algo desde el servlet --%>
    <%
        Object err = request.getAttribute("error");
        if (err != null) {
    %>
    <div class="alert alert-danger"><%= err %></div>
    <% } %>

    <%
        // Si existe usuariosCombo -> pantalla de selección; si no, mostramos el perfil
        List<Map<String, Object>> usuariosCombo =
                (List<Map<String, Object>>) request.getAttribute("usuariosCombo");

        DTUsuario usuario = null;
        boolean esProponente = false;
        Boolean esPropio = null;
        boolean esColaborador = false;

        if (usuariosCombo != null) {
    %>
    <!-- PANTALLA 1: selector de usuario -->
    <form method="get" action="<%=ctx%>/consultaPerfilUsuario" class="row g-2 align-items-end">
        <div class="col-12 col-md-6">
            <label class="form-label">Elegí un usuario</label>
            <select name="nick" class="form-select">
                <% for (Map<String, Object> u : usuariosCombo) {
                    String nickOpt = (String) u.get("nick");
                    String tipoOpt = (String) u.get("tipo");
                    Long   idOpt   = (Long)   u.get("id"); %>
                <option value="<%= nickOpt %>">
                    <%= nickOpt %> — <%= tipoOpt %> (#<%= idOpt %>)
                </option>
                <% } %>
            </select>
        </div>
        <div class="col-12 col-md-auto">
            <button type="submit" class="btn btn-primary">Ver perfil</button>
        </div>
    </form>

    <%
    } else {
        // PANTALLA 2: vista de perfil
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

    <!-- Cabecera de perfil -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h2 class="h4 mb-3">Perfil de <%= (usuario != null ? usuario.getNickname() : request.getParameter("nick")) %></h2>
            <div class="d-flex gap-3 align-items-start">
                <% if (usuario != null && usuario.getImagen() != null && !usuario.getImagen().isBlank()) { %>
                <img alt="avatar" src="<%=usuario.getImagen()%>" class="rounded-circle border" style="width:96px;height:96px;object-fit:cover">
                <% } %>
                <div>
                    <div class="mb-1">
                        <span class="badge <%= esProponente ? "text-bg-primary" : (esColaborador ? "text-bg-success" : "text-bg-secondary") %>">
                            <%= esProponente ? "Proponente" : (esColaborador ? "Colaborador" : "Usuario") %>
                        </span>
                        <% if (esPropio != null && esPropio) { %>
                        <span class="ms-2 text-muted small">Estás viendo tu propio perfil</span>
                        <% } %>
                    </div>
                    <% if (usuario != null) { %>
                    <div><b>Nombre:</b> <%=usuario.getNombre()%> <%=usuario.getApellido()%></div>
                    <div><b>Correo:</b> <%=usuario.getCorreo()%></div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Seguidores -->
        <div class="col-12 col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h3 class="h5">Seguidores</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr><th>Nickname</th><th>Tipo</th><th class="text-center">Acciones</th></tr>
                        </thead>
                        <tbody>
                        <% boolean hayFollowers = false; %>
                        <% if (followersProponentes != null) {
                            for (String n : followersProponentes) { hayFollowers = true; %>
                        <tr>
                            <td><%=n%></td>
                            <td><span class="badge text-bg-primary">Proponente</span></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
                        </tr>
                        <% } } %>
                        <% if (followersColaboradores != null) {
                            for (String n : followersColaboradores) { hayFollowers = true; %>
                        <tr>
                            <td><%=n%></td>
                            <td><span class="badge text-bg-success">Colaborador</span></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
                        </tr>
                        <% } } %>
                        <% if (!hayFollowers) { %>
                        <tr><td colspan="3" class="text-center text-muted">(sin seguidores)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Siguiendo -->
        <div class="col-12 col-lg-6">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h3 class="h5">Siguiendo</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr><th>Nickname</th><th>Tipo</th><th class="text-center">Acciones</th></tr>
                        </thead>
                        <tbody>
                        <% boolean haySiguiendo = false; %>
                        <% if (siguiendoProponentes != null) {
                            for (String n : siguiendoProponentes) { haySiguiendo = true; %>
                        <tr>
                            <td><%=n%></td>
                            <td><span class="badge text-bg-primary">Proponente</span></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
                        </tr>
                        <% } } %>
                        <% if (siguiendoColaboradores != null) {
                            for (String n : siguiendoColaboradores) { haySiguiendo = true; %>
                        <tr>
                            <td><%=n%></td>
                            <td><span class="badge text-bg-success">Colaborador</span></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPerfilUsuario?nick=<%=n%>">Ver perfil</a></td>
                        </tr>
                        <% } } %>
                        <% if (!haySiguiendo) { %>
                        <tr><td colspan="3" class="text-center text-muted">(no sigue a nadie)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Favoritas -->
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h3 class="h5">Propuestas favoritas</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr><th>Título</th><th class="text-center">Acciones</th></tr>
                        </thead>
                        <tbody>
                        <% if (favoritas != null && !favoritas.isEmpty()) {
                            for (DTPropuesta p : favoritas) { %>
                        <tr>
                            <td><%=p.getTitulo()%></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPropuesta?accion=detalle&titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="2" class="text-center text-muted">(sin favoritas)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <% if (esProponente) { %>
        <!-- Publicadas (no INGRESADA) -->
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h3 class="h5">Publicadas (no INGRESADA)</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr><th>Título</th><th>Estado</th><th class="text-center">Acciones</th></tr>
                        </thead>
                        <tbody>
                        <% if (publicadasNoIngresada != null && !publicadasNoIngresada.isEmpty()) {
                            for (DTPropuesta p : publicadasNoIngresada) { %>
                        <tr>
                            <td><%=p.getTitulo()%></td>
                            <td><span class="badge text-bg-secondary"><%=p.getEstadoActual()%></span></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPropuesta?accion=detalle&titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="3" class="text-center text-muted">(sin propuestas publicadas fuera de INGRESADA)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <% } %>

        <% if (esColaborador) { %>
        <!-- Colaboradas -->
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h3 class="h5">Propuestas colaboradas</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>Título</th><th>Fecha y Hora</th><th>Monto</th><th>Acciones</th>
                        </thead>

                        <%--Muestro Propuestas con las que colaboró--%>
                        <tbody>
                        <% if (colaboradas != null && !colaboradas.isEmpty()) {
                            //Fomateo la fecha y hora para que tenga una apariencia más linda a la vista
                            DateTimeFormatter fmtUY = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm", new Locale("es","UY"));
                            for (DTColaboracion m : misColaboraciones){
                                DTPropuesta prop = m.getPropuesta();
                        %>
                        <tr>
                        <td><%=prop.getTitulo()%></td>
                        <td><%= (m.getFechaHora() != null) ? m.getFechaHora().format(fmtUY) : "-" %></td>
                        <td><%=m.getMonto()%></td>
                        <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPropuesta?accion=detalle&titulo=<%=prop.getTitulo()%>">Ver detalle</a></td>
                    </tr>
                        <% } } else { %>
                        <tr><td colspan="2" class="text-center text-muted">(sin colaboraciones)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <% } %>

        <% if (esPropio != null && esPropio && esProponente) { %>
        <!-- (Propio) Mis INGRESADAS -->
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h3 class="h5">Mis propuestas en estado INGRESADA</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr><th>Título</th><th>Estado</th><th class="text-center">Acciones</th></tr>
                        </thead>
                        <tbody>
                        <% if (creadasIngresadas != null && !creadasIngresadas.isEmpty()) {
                            for (DTPropuesta p : creadasIngresadas) { %>
                        <tr>
                            <td><%=p.getTitulo()%></td>
                            <td><span class="badge text-bg-secondary"><%=p.getEstadoActual()%></span></td>
                            <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPropuesta?accion=detalle&titulo=<%=p.getTitulo()%>">Ver detalle</a></td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="3" class="text-center text-muted">(sin propuestas en estado INGRESADA)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <% } %>
    </div> <!-- row -->

    <!-- Acciones inferiores -->
    <div class="d-flex gap-2 mt-4">
        <button type="button" class="btn btn-outline-secondary"
                onclick="location.href='${pageContext.request.contextPath}/principal'">Volver al inicio
        </button>

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
            <button type="submit" class="btn <%= loSigo ? "btn-outline-danger" : "btn-primary" %>">
                <%= loSigo ? "Dejar de seguir" : "Seguir" %>
            </button>
        </form>
        <% } %>
    </div>

    <% } // fin if usuariosCombo %>
</div> <!-- container -->
</body>
</html>