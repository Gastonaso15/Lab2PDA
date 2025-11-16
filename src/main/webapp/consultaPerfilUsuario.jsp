<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="culturarte.servicios.cliente.usuario.*" %>
<%@ page import="culturarte.servicios.cliente.propuestas.DtPropuesta" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Perfil de Usuario</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">
<% String ctx = request.getContextPath(); %>

<div class="container py-4">
    <jsp:include page="cabezalComun.jsp"/>
    <h1 class="h3 mb-4">Consulta de Perfil de Usuario</h1>

    <%
        Object err = request.getAttribute("error");
        if (err != null) {
    %>
    <div class="alert alert-danger"><%= err %></div>
    <% } %>

    <%
        List<Map<String, Object>> usuariosCombo =
                (List<Map<String, Object>>) request.getAttribute("usuariosCombo");

        DtUsuario usuario = null;
        boolean esProponenteC = false;
        Boolean esPropio = null;
        boolean esColaboradorC = false;

        boolean esProponente = false;
        boolean esColaborador = false;

        if (usuariosCombo != null) {
    %>
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <h2 class="h5 mb-0">Elegí un usuario</h2>

                <div class="input-group" style="max-width: 420px;">
        <span class="input-group-text">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor"
               class="bi bi-search" viewBox="0 0 16 16">
            <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85zm-5.242.656a5 5 0 1 1 0-10 5 5 0 0 1 0 10z"/>
          </svg>
        </span>
                    <input id="filtroUsuarios" type="text" class="form-control"
                           placeholder="Buscar por nick, nombre o apellido...">
                </div>
            </div>

            <div class="row g-3" id="gridUsuarios">
                <%
                    for (Map<String, Object> u : usuariosCombo) {
                        String nickOpt     = String.valueOf(u.get("nick"));
                        String nombreOpt   = String.valueOf(u.getOrDefault("nombre",""));
                        String apellidoOpt = String.valueOf(u.getOrDefault("apellido",""));
                        String tipoOpt     = String.valueOf(u.getOrDefault("tipo","Usuario"));
                        String img         = (String) u.get("imagen");
                        String rutaImagen  = (img == null || img.isBlank()) ? (ctx + "/imagenes/usuarioDefault.png") : (ctx + "/" + img);

                        String badgeClass = "text-bg-secondary";
                        if ("Proponente".equalsIgnoreCase(tipoOpt))  badgeClass = "text-bg-primary";
                        else if ("Colaborador".equalsIgnoreCase(tipoOpt)) badgeClass = "text-bg-success";
                %>
                <div class="col-12 col-sm-6 col-lg-4 col-xl-3 user-card"
                     data-nick="<%= nickOpt.toLowerCase() %>"
                     data-nombre="<%= nombreOpt.toLowerCase() %>"
                     data-apellido="<%= apellidoOpt.toLowerCase() %>">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body d-flex gap-3">
                            <img src="<%= rutaImagen %>" alt="avatar" class="rounded-circle border"
                                 style="width:64px;height:64px;object-fit:cover">
                            <div class="flex-grow-1">
                                <div class="d-flex align-items-center gap-2 mb-1">
                                    <span class="badge <%= badgeClass %>"><%= tipoOpt %></span>
                                </div>
                                <div class="fw-semibold"><%= nickOpt %></div>
                                <div class="text-muted small"><%= nombreOpt %> <%= apellidoOpt %></div>
                                <div class="mt-2">
                                    <a class="btn btn-sm btn-primary"
                                       href="<%= ctx %>/consultaPerfilUsuario?nick=<%= nickOpt %>">
                                        Ver perfil
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        (function() {
            const input = document.getElementById('filtroUsuarios');
            const cards = document.querySelectorAll('#gridUsuarios .user-card');
            if (!input) return;

            input.addEventListener('input', function () {
                const q = this.value.trim().toLowerCase();
                cards.forEach(card => {
                    const nick = card.dataset.nick || "";
                    const nombre = card.dataset.nombre || "";
                    const apellido = card.dataset.apellido || "";
                    const match = !q || nick.includes(q) || nombre.includes(q) || apellido.includes(q);
                    card.classList.toggle('d-none', !match);
                });
            });
        })();
    </script>

    <%
    } else {
        usuario = (DtUsuario) request.getAttribute("usuarioConsultado");
        esPropio = (Boolean) request.getAttribute("esPropio");
        esProponenteC = request.getAttribute("esProponenteC") != null && (Boolean) request.getAttribute("esProponenteC");
        esColaboradorC = request.getAttribute("esColaboradorC") != null && (Boolean) request.getAttribute("esColaboradorC");

        esProponente = request.getAttribute("esProponente") != null && (Boolean) request.getAttribute("esProponente");
        esColaborador = request.getAttribute("esColaborador") != null && (Boolean) request.getAttribute("esColaborador");

        List<String> siguiendoProponentes = (List<String>) request.getAttribute("siguiendoProponentes");
        List<String> siguiendoColaboradores = (List<String>) request.getAttribute("siguiendoColaboradores");
        List<String> followersProponentes = (List<String>) request.getAttribute("followersProponentes");
        List<String> followersColaboradores = (List<String>) request.getAttribute("followersColaboradores");

        List<DtPropuesta> favoritas = (List<DtPropuesta>) request.getAttribute("favoritas");
        List<culturarte.servicios.cliente.usuario.DtPropuesta> publicadasNoIngresada = (List<culturarte.servicios.cliente.usuario.DtPropuesta>) request.getAttribute("publicadasNoIngresada");
        List<culturarte.servicios.cliente.usuario.DtPropuesta> colaboradas = (List<culturarte.servicios.cliente.usuario.DtPropuesta>) request.getAttribute("colaboradas");
        List<culturarte.servicios.cliente.usuario.DtPropuesta> creadasIngresadas = (List<culturarte.servicios.cliente.usuario.DtPropuesta>) request.getAttribute("creadasIngresadas");
        List<DtColaboracion> misColaboraciones = (List<DtColaboracion>) request.getAttribute("misColaboraciones");

        String bio = (String) request.getAttribute("bio");
        String sitioWeb = (String) request.getAttribute("sitioWeb");
    %>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h2 class="h4 mb-3">Perfil de <%= (usuario != null ? usuario.getNickname() : request.getParameter("nick")) %></h2>
            <div class="d-flex gap-3 align-items-start">

               <%String rutaImagen = (usuario != null) ? usuario.getImagen() : null;
                   if (rutaImagen == null || rutaImagen.isBlank()) {
                       rutaImagen = ctx + "/imagenes/usuarioDefault.png";
                   } else {
                       rutaImagen = ctx + "/" + rutaImagen;
                   }%>
               <img alt="avatar" src="<%= rutaImagen %>" class="rounded-circle border" style="width:96px;height:96px;object-fit:cover">
                <div>
                    <div class="mb-1">
                        <span class="badge <%= esProponenteC ? "text-bg-primary" : (esColaboradorC ? "text-bg-success" : "text-bg-secondary") %>">
                            <%= esProponenteC ? "Proponente" : (esColaboradorC ? "Colaborador" : "Usuario") %>
                        </span>
                        <% if (esPropio != null && esPropio) { %>
                        <span class="ms-2 text-muted small">Estás viendo tu propio perfil</span>
                        <% } %>
                    </div>
                    <% if (usuario != null) { %>
                    <div><b>Nombre:</b> <%=usuario.getNombre()%> <%=usuario.getApellido()%></div>
                    <div><b>Correo:</b> <%=usuario.getCorreo()%></div>
                    <% } %>

                    <%
                       if (esProponenteC) {

                           if (bio != null && !bio.isBlank()) { %>
                               <div><b>Biografía:</b> <%=bio%></div>
                           <% }

                           if (sitioWeb != null && !sitioWeb.isBlank()) {
                               String sitioWebURL = sitioWeb;
                               if (!sitioWebURL.toLowerCase().startsWith("http")) {
                                   sitioWebURL = "http://" + sitioWebURL;
                               }
                           %>
                               <div><b>Sitio Web:</b> <a href="<%=sitioWebURL%>" target="_blank"><%=sitioWeb%></a></div>
                           <% }
                       }
                    %>
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
                            for (culturarte.servicios.cliente.propuestas.DtPropuesta p : favoritas) { %>
                        <tr>
                            <td><%= p.getTitulo() %></td>
                            <td class="text-center">
                                <a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPropuesta?accion=detalle&titulo=<%= p.getTitulo() %>">Ver detalle</a>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="2" class="text-center text-muted">(sin favoritas)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <% if (esProponenteC) { %>
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h3 class="h5">Publicadas</h3>
                    <table class="table table-sm table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr><th>Título</th><th>Estado</th><th class="text-center">Acciones</th></tr>
                        </thead>
                        <tbody>
                        <% if (publicadasNoIngresada != null && !publicadasNoIngresada.isEmpty()) {
                            for (culturarte.servicios.cliente.usuario.DtPropuesta p : publicadasNoIngresada) { %>
                        <tr>
                            <td><%=p.getTitulo()%></td>
                            <td><span class="badge text-bg-secondary"><%=p.getEstadoActual() != null ? p.getEstadoActual().toString() : ""%></span></td>
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

        <% if (esColaboradorC) { %>
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

                        <tbody>
                        <% if (colaboradas != null && !colaboradas.isEmpty()) {
                            for (DtColaboracion m : misColaboraciones) {
                                culturarte.servicios.cliente.usuario.DtPropuesta prop = m.getPropuesta();
                        %>
                        <tr>
                        <td><%=prop.getTitulo()%></td>
                            <%--si esta en su propio perfil es la unica manera de que vea el monto y fecha--%>
                            <% if (esPropio != null && esPropio ){%>
                        <td><%m.getFechaHora();%></td>
                        <td><%=m.getMonto()%></td>
                            <%}else{%>
                            <td>- </td>
                            <td>-</td>
                            <%}%>
                        <td class="text-center"><a class="btn btn-link btn-sm" href="<%=ctx%>/consultaPropuesta?accion=detalle&titulo=<%=prop.getTitulo()%>">Ver detalle</a></td>
                    </tr>
                        <% }}  else { %>
                        <tr><td colspan="2" class="text-center text-muted">(sin colaboraciones)</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <% } %>

        <% if (esPropio != null && esPropio && esProponenteC) { %>
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
                            for (culturarte.servicios.cliente.usuario.DtPropuesta p : creadasIngresadas) { %>
                        <tr>
                            <td><%=p.getTitulo()%></td>
                            <td><span class="badge text-bg-secondary"><%=p.getEstadoActual() != null ? p.getEstadoActual().toString() : ""%></span></td>
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
    </div>

    <div class="d-flex gap-2 mt-4">
        <button type="button" class="btn btn-outline-secondary"
                onclick="location.href='${pageContext.request.contextPath}/principal'">Volver al inicio
        </button>

        <%
            DtUsuario usuarioConsultadoBtn = (DtUsuario) request.getAttribute("usuarioConsultado");
            String nickConsultadoBtn = (usuarioConsultadoBtn != null)
                    ? usuarioConsultadoBtn.getNickname()
                    : request.getParameter("nick");

            DtUsuario usuarioActualBtn = (DtUsuario) session.getAttribute("usuarioLogueado");
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
        <% if (esPropio != null && esPropio && esProponenteC) { %>
            <a href="<%= request.getContextPath() %>/bajaProponente"
               class="btn btn-danger">
                <i class="bi bi-trash"></i> Dar de Baja Mi Cuenta
            </a>
        <% } %>
    </div>

    <% } // fin if usuariosCombo %>
</div>
</body>
</html>