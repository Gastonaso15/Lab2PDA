<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="culturarte.servicios.cliente.usuario.*" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <title>Ranking de Usuarios</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap 5 (CDN) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">
<% String ctx = request.getContextPath(); %>

<div class="container py-4">
    <jsp:include page="cabezalComun.jsp"/>
    <h1 class="h3 mb-4">Ranking de Usuarios</h1>

    <%-- Mensaje de error si pasó algo desde el servlet --%>
        <%
        Object err = request.getAttribute("error");
        if (err != null) {
    %>
    <div class="alert alert-danger"><%= err %></div>
        <% } %>

        <%
        List<Map<String, Object>> usuariosCombo =
                (List<Map<String, Object>>) request.getAttribute("usuariosCombo");

    %>
    <!-- Ranking de usuarios -->
        <!-- Ranking de usuarios (grilla) -->
        <div class="row g-3"><%  // <-- ESTA ES LA GRILLA
            for (Map<String, Object> u : usuariosCombo) {
                String nickOpt    = String.valueOf(u.get("nick"));
                String nombreOpt  = String.valueOf(u.getOrDefault("nombre",""));
                String apellidoOpt= String.valueOf(u.getOrDefault("apellido",""));
                String tipoOpt    = String.valueOf(u.getOrDefault("tipo","Usuario"));
                int    segOpt     = ((Number)u.getOrDefault("cantFollowers",0)).intValue();
                long   idOpt      = ((Number)u.getOrDefault("id",0)).longValue();
                int    rankOpt    = ((Number)u.getOrDefault("rank",0)).intValue();

                // imagen ya viene del servlet; fallback por si viniera vacía
                String rutaImagen = (String) u.get("imagen");
                if (rutaImagen == null || rutaImagen.isBlank()) {
                    rutaImagen = ctx + "/imagenes/usuarioDefault.png";
                } else {
                    rutaImagen = ctx + "/" + rutaImagen;
                }

                String badgeClass = "text-bg-secondary";
                if ("Proponente".equalsIgnoreCase(tipoOpt)) badgeClass = "text-bg-primary";
                else if ("Colaborador".equalsIgnoreCase(tipoOpt)) badgeClass = "text-bg-success";
        %>
            <!-- TARJETA INDIVIDUAL -->
            <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
                <div class="card shadow-sm h-100 position-relative">
                    <!-- N° de ranking arriba a la izquierda -->
                    <span class="position-absolute top-0 start-0 translate-middle badge rounded-pill bg-dark"
                          style="z-index: 2; left: .75rem!important; top: .75rem!important;">
                <%= rankOpt %>
            </span>

                    <div class="card-body d-flex gap-3">
                        <img src="<%= rutaImagen %>" alt="avatar" class="rounded-circle border"
                             style="width:64px;height:64px;object-fit:cover">
                        <div class="flex-grow-1">
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <span class="badge <%= badgeClass %>"><%= tipoOpt %></span>
                                <span class="text-muted small"><%= segOpt %> seg.</span>
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
            <% } %></div>

</body>
</html>
