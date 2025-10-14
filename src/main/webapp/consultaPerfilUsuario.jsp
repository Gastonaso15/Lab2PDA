<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="culturarte.logica.DTs.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Perfil de Usuario</title>
    <style>
        .tabs { margin-top: 16px; }
        .tab-buttons { display: flex; gap: 8px; flex-wrap: wrap; }
        .tab-buttons button { padding: 8px 12px; border: 1px solid #555; background: #111; color: #eee; cursor: pointer; border-radius: 8px; }
        .tab-buttons button.active { background: #333; }
        .tab-content { border: 1px solid #555; border-radius: 12px; padding: 12px; margin-top: 8px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px,1fr)); gap: 10px; }
        .card { border: 1px solid #444; border-radius: 10px; padding: 10px; background: #1a1a1a; color: #eee; }
        img.avatar { width: 100px; height: 100px; object-fit: cover; border-radius: 10px; border: 1px solid #555; }
        .pill { display:inline-block; padding:2px 8px; border:1px solid #666; border-radius:999px; font-size:12px; margin-left:6px;}
        .row { display:flex; align-items:center; gap:12px; flex-wrap: wrap; }
        .muted { color:#aaa; font-size: 0.9em; }
        .error { color: #ff8080; margin: 8px 0; }
        a.btn { padding:6px 10px; border:1px solid #777; border-radius:8px; text-decoration:none; color:#eee; }
    </style>
    <script>
        function showTab(id) {
            document.querySelectorAll('.tab-pane').forEach(p => p.style.display = 'none');
            document.querySelectorAll('.tab-buttons button').forEach(b => b.classList.remove('active'));
            document.getElementById(id).style.display = 'block';
            document.querySelector('[data-tab="'+id+'"]').classList.add('active');
        }
        document.addEventListener('DOMContentLoaded', () => {
            const first = document.querySelector('.tab-pane');
            if (first) showTab(first.id);
        });
    </script>
</head>
<body style="background:#0d0d0d; color:#eee; font-family: system-ui, -apple-system, Segoe UI, Roboto;">

<% String ctx = request.getContextPath(); %>

<h1>Consulta de Perfil de Usuario</h1>

<% if (request.getAttribute("error") != null) { %>
<div class="error"><%= request.getAttribute("error") %></div>
<% } %>

<%
    @SuppressWarnings("unchecked")
    List<String> nicknames = (List<String>) request.getAttribute("nicknames");
    if (nicknames != null) {
%>
<!-- Lista inicial de usuarios -->
<form method="get" action="<%= ctx %>/consultaPerfilUsuario">
    <label>Elegí un usuario:</label>
    <select name="nick">
        <% for (String n : nicknames) { %>
        <option value="<%= n %>"><%= n %></option>
        <% } %>
    </select>
    <button type="submit">Ver perfil</button>
</form>
<%
} else {
    DTUsuario usuario = (DTUsuario) request.getAttribute("usuarioConsultado");
    Boolean esPropio = (Boolean) request.getAttribute("esPropio");
    DTUsuario actual = (DTUsuario) request.getAttribute("usuarioActual");
    boolean loSigo = request.getAttribute("loSigo") != null && (Boolean) request.getAttribute("loSigo");

    boolean esProponente = request.getAttribute("esProponente") != null && (Boolean) request.getAttribute("esProponente");
    boolean esColaborador = request.getAttribute("esColaborador") != null && (Boolean) request.getAttribute("esColaborador");

    List<String> siguiendoNicks = (List<String>) request.getAttribute("siguiendoNicks");
    List<String> seguidoresNicks = (List<String>) request.getAttribute("seguidoresNicks");
    Map<String,String> tipoPorNick = (Map<String,String>) request.getAttribute("tipoPorNick");

    List<DTPropuesta> favoritas = (List<DTPropuesta>) request.getAttribute("favoritas");
    List<DTPropuesta> publicadasNoIngresada = (List<DTPropuesta>) request.getAttribute("publicadasNoIngresada");
    List<DTPropuesta> colaboradas = (List<DTPropuesta>) request.getAttribute("colaboradas");
    List<DTPropuesta> creadasIngresadas = (List<DTPropuesta>) request.getAttribute("creadasIngresadas");
    List<DTColaboracion> misColaboraciones = (List<DTColaboracion>) request.getAttribute("misColaboraciones");
%>

<div class="row">
    <% if (usuario.getImagen() != null && !usuario.getImagen().isBlank()) { %>
    <img class="avatar" alt="avatar" src="<%= usuario.getImagen() %>"/>
    <% } %>

    <div>
        <h2 style="margin:0">Perfil de <%= usuario.getNickname() %></h2>
        <div class="muted">
            <%= usuario.getNombre() %> <%= usuario.getApellido() %>
            <span class="pill"><%= esProponente ? "Proponente" : (esColaborador ? "Colaborador" : "Usuario") %></span>
        </div>

        <% if (actual != null && !esPropio) { %>
        <form class="row" action="<%= ctx %>/seguimientoDeUsuario" method="post" style="margin-top:8px">
            <input type="hidden" name="seguido" value="<%= usuario.getNickname() %>">
            <button type="submit"><%= loSigo ? "Dejar de seguir" : "Seguir" %></button>
        </form>
        <% } %>

        <% if (esPropio != null && esPropio) { %>
        <div style="margin-top:6px" class="muted">Estás viendo tu propio perfil.</div>
        <% } %>
    </div>
</div>

<div class="tabs">
    <div class="tab-buttons">
        <button type="button" data-tab="tab-info"            onclick="showTab('tab-info')">Información</button>
        <button type="button" data-tab="tab-rel"             onclick="showTab('tab-rel')">Seguidores / Siguiendo</button>
        <button type="button" data-tab="tab-favs"            onclick="showTab('tab-favs')">Favoritas</button>
        <% if (esProponente) { %>
        <button type="button" data-tab="tab-publicadas"      onclick="showTab('tab-publicadas')">Publicadas (no INGRESADA)</button>
        <% } %>
        <% if (esColaborador) { %>
        <button type="button" data-tab="tab-colaboradas"     onclick="showTab('tab-colaboradas')">Colaboradas</button>
        <% } %>
        <% if (esPropio && esProponente) { %>
        <button type="button" data-tab="tab-ingresadas"      onclick="showTab('tab-ingresadas')">Mis INGRESADAS</button>
        <% } %>
        <% if (esPropio && esColaborador) { %>
        <button type="button" data-tab="tab-miscolabs"       onclick="showTab('tab-miscolabs')">Mis colaboraciones</button>
        <% } %>
    </div>

    <!-- Información básica -->
    <div class="tab-content tab-pane" id="tab-info" style="display:none">
        <div class="grid">
            <div class="card">
                <b>Nickname:</b> <%= usuario.getNickname() %><br/>
                <b>Nombre:</b> <%= usuario.getNombre() %><br/>
                <b>Apellido:</b> <%= usuario.getApellido() %><br/>
                <b>Correo:</b> <%= usuario.getCorreo() %><br/>
            </div>
        </div>
    </div>

    <!-- Seguidores / Siguiendo -->
    <div class="tab-content tab-pane" id="tab-rel" style="display:none">
        <h3>Seguidores</h3>
        <div class="grid">
            <% if (seguidoresNicks != null) for (String n : seguidoresNicks) { %>
            <div class="card">
                <b><%= n %></b>
                <span class="pill"><%= tipoPorNick.getOrDefault(n,"Usuario") %></span><br/>
                <a class="btn" href="<%= ctx %>/consultaPerfilUsuario?nick=<%= n %>">Ver perfil</a>
            </div>
            <% } %>
        </div>

        <h3 style="margin-top:16px">Siguiendo</h3>
        <div class="grid">
            <% if (siguiendoNicks != null) for (String n : siguiendoNicks) { %>
            <div class="card">
                <b><%= n %></b>
                <span class="pill"><%= tipoPorNick.getOrDefault(n,"Usuario") %></span><br/>
                <a class="btn" href="<%= ctx %>/consultaPerfilUsuario?nick=<%= n %>">Ver perfil</a>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Favoritas -->
    <div class="tab-content tab-pane" id="tab-favs" style="display:none">
        <div class="grid">
            <% if (favoritas != null) for (DTPropuesta p : favoritas) { %>
            <div class="card">
                <b><%= p.getTitulo() %></b><br/>
                <a class="btn" href="<%= ctx %>/consultaPropuesta?titulo=<%= p.getTitulo() %>">Ver detalle</a>
            </div>
            <% } %>
        </div>
    </div>

    <% if (esProponente) { %>
    <!-- Publicadas (no INGRESADA) -->
    <div class="tab-content tab-pane" id="tab-publicadas" style="display:none">
        <div class="grid">
            <% if (publicadasNoIngresada != null) for (DTPropuesta p : publicadasNoIngresada) { %>
            <div class="card">
                <b><%= p.getTitulo() %></b>
                <span class="pill"><%= p.getEstadoActual() %></span><br/>
                <a class="btn" href="<%= ctx %>/consultaPropuesta?titulo=<%= p.getTitulo() %>">Ver detalle</a>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <% if (esColaborador) { %>
    <!-- Colaboradas -->
    <div class="tab-content tab-pane" id="tab-colaboradas" style="display:none">
        <div class="grid">
            <% if (colaboradas != null) for (DTPropuesta p : colaboradas) { %>
            <div class="card">
                <b><%= p.getTitulo() %></b><br/>
                <a class="btn" href="<%= ctx %>/consultaPropuesta?titulo=<%= p.getTitulo() %>">Ver detalle</a>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <% if (esPropio && esProponente) { %>
    <!-- (Propio) Mis INGRESADAS -->
    <div class="tab-content tab-pane" id="tab-ingresadas" style="display:none">
        <div class="grid">
            <% if (creadasIngresadas != null) for (DTPropuesta p : creadasIngresadas) { %>
            <div class="card">
                <b><%= p.getTitulo() %></b>
                <span class="pill"><%= p.getEstadoActual() %></span><br/>
                <a class="btn" href="<%= ctx %>/consultaPropuesta?titulo=<%= p.getTitulo() %>">Ver detalle</a>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <% if (esPropio && esColaborador) { %>
    <!-- (Propio) Mis colaboraciones (monto/fecha) -->
    <div class="tab-content tab-pane" id="tab-miscolabs" style="display:none">
        <div class="grid">
            <% if (misColaboraciones != null) for (DTColaboracion c : misColaboraciones) { %>
            <div class="card">
                <b><%= c.getPropuesta() != null ? c.getPropuesta().getTitulo() : "(Propuesta)" %></b><br/>
                <span>Monto: </span><%= c.getMonto() %><br/>
                <%-- Si tu DTO trae fecha, mostrála. Si no, podés omitirla. --%>
                <%-- <span>Fecha: </span><%= c.getFecha() %> --%><br/>
                <% if (c.getPropuesta() != null) { %>
                <a class="btn" href="<%= ctx %>/consultaPropuesta?titulo=<%= c.getPropuesta().getTitulo() %>">Ver detalle</a>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>

</div>
<% } %>

</body>
</html>