<%@ page import="culturarte.logica.DTs.DTUsuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<header>
    <div class="logo">
        <a href="<%= request.getContextPath() %>/principal" style="text-decoration: none;">
            <img src="imagenes/culturarte.png" alt="Logo Culturarte" style="width:150px; height:auto;">
        </a>
    </div>
    <div class="Botones-Menu-Superior">
        <%
            Boolean esProponente = (Boolean) request.getAttribute("esProponente");
            if (esProponente != null && esProponente) {
        %>
            <a href="altaPropuesta">Nueva Propuesta</a> |
            <a href="extenderFinanciacion">Quiero Extender financiacion </a> |
            <% } %>
        <a href="consultaPropuesta">Ver Propuestas</a> |
        <a href="consultaPerfilUsuario">Ver Usuarios</a>
        <%
            Boolean esColaborador = (Boolean) request.getAttribute("esColaborador");
            if (esColaborador != null && esColaborador) {
        %>
          | <a href="listarPropuestasParaComentar">Comentar Propuestas</a>
        <% } %>
    </div>
    <div class="search-bar-Menu-Superior">
        <form method="get" action="<%= request.getContextPath() %>/principal" style="display: flex; gap: 10px; width: 100%;">
            <input type="text" name="busqueda" placeholder="Buscar por título, lugar o descripción..." 
                   value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>"
                   style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
            <button type="submit" style="padding: 10px 20px; background-color: #333; color: white; border: none; border-radius: 4px; cursor: pointer;">Buscar</button>
            <% if (request.getParameter("busqueda") != null && !request.getParameter("busqueda").isEmpty()) { %>
                <a href="<%= request.getContextPath() %>/principal" 
                   style="padding: 10px 15px; background-color: #666; color: white; text-decoration: none; border-radius: 4px; display: flex; align-items: center;">
                    Limpiar
                </a>
            <% } %>
        </form>
    </div>
     <div class="Botones-Menu-Superior">
            <%Object usuarioObj = session.getAttribute("usuarioLogueado");
            if(usuarioObj != null) {
                DTUsuario usuario = (DTUsuario) usuarioObj;%>
                <div style="display:flex; align-items:center; gap:10px;">
                   <%
                       String rutaImagen = usuario.getImagen();
                       if (rutaImagen == null || rutaImagen.isEmpty()) {
                           rutaImagen = request.getContextPath() + "/imagenes/usuarioDefault.png";
                       } else {
                           rutaImagen = request.getContextPath() + "/" + rutaImagen;
                       }
                   %>
                   <img src="<%= rutaImagen %>" alt="Imagen de Usuario" style="width:40px; height:40px; border-radius:50%;">
                   <div style="display:flex; flex-direction:column;">
                        <span><%= usuario.getNombre() %> <%= usuario.getApellido() %></span>
                        <span style="font-size:13px;">
                            <a href="<%= request.getContextPath() %>/consultaPerfilUsuario?nick=<%= usuario.getNickname() %>" style="text-decoration:none; color:#333;">Perfil</a> |
                            <a href="${pageContext.request.contextPath}/cierreSesion" style="text-decoration:none; color:#333;">Cerrar Sesión </a>

                        </span>
                    </div>
                </div>
            <%}else{%>
                <a href="altaPerfil">REGISTRARSE</a> |
                <a href="inicioDeSesion">ENTRAR</a>
            <%}%>
        </div>
</header>
