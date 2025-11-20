<%@ page import="culturarte.servicios.cliente.usuario.DtUsuario, culturarte.servicios.cliente.imagenes.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<header>
    <div class="menu-hamburguesa">
        <button class="menu-toggle" id="menuToggle" aria-label="Abrir menú">
            <span></span>
            <span></span>
            <span></span>
        </button>
    </div>
    
    <div class="logo">
        <a href="<%= request.getContextPath() %>/principal" style="text-decoration: none;">
            <img src="imagenes/culturarte.png" alt="Logo Culturarte" style="width:150px; height:auto;">
        </a>
    </div>
    
    <div class="sidebar-menu" id="sidebarMenu">
        <div class="sidebar-header">
            <h3>Menú</h3>
            <button class="sidebar-close" id="sidebarClose" aria-label="Cerrar menú">&times;</button>
        </div>
        <nav class="sidebar-nav">
            <%
                Boolean esProponente = (Boolean) request.getAttribute("esProponente");
                Boolean esColaborador = (Boolean) request.getAttribute("esColaborador");
                
                if (esProponente != null && esProponente) {
            %>
                <a href="<%= request.getContextPath() %>/altaPropuesta" class="sidebar-item">
                    <span>📝</span> Nueva Propuesta
                </a>
                <a href="<%= request.getContextPath() %>/ejecutarPropuesta" class="sidebar-item">
                    <span>▶️</span> Ejecutar Propuestas
                </a>
            <%
                }
                
                if (esColaborador != null && esColaborador) {
            %>
                <a href="<%= request.getContextPath() %>/recomendacionPropuestas" class="sidebar-item">
                    <span>⭐</span> Recomendaciones de Propuestas
                </a>
                <a href="<%= request.getContextPath() %>/listarPropuestasParaComentar" class="sidebar-item">
                    <span>💬</span> Comentar Propuestas
                </a>
                <a href="<%= request.getContextPath() %>/listarColaboracionesConstancia" class="sidebar-item">
                    <span>📄</span> Constancias de Pago
                </a>
                <a href="<%= request.getContextPath() %>/listarColaboracionesParaPagar" class="sidebar-item">
                    <span>💳</span> Pagar Colaboración
                </a>
            <%
                }
            %>
            <a href="<%= request.getContextPath() %>/VerRankingDeUsuarios" class="sidebar-item">
                <span>🏆</span> Ver Ranking de Usuarios
            </a>
        </nav>
    </div>
    
    <div class="sidebar-overlay" id="sidebarOverlay"></div>
    
    <div class="Botones-Menu-Superior">
        <a href="consultaPropuesta">Ver Propuestas</a> |
        <a href="consultaPerfilUsuario">Ver Usuarios</a>
    </div>

    <div class="search-bar-Menu-Superior">
        <form method="get" action="<%= request.getContextPath() %>/consultaPropuesta" style="display: flex; gap: 10px; width: 100%;">
            <input type="text" name="busqueda" placeholder="Buscar por título, lugar o descripción..."
                   value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>"
                   style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
            <button type="submit" style="padding: 10px 20px; background-color: #333; color: white; border: none; border-radius: 4px; cursor: pointer;">Buscar</button>
            <% if (request.getParameter("busqueda") != null && !request.getParameter("busqueda").isEmpty()) { %>
                <a href="<%= request.getContextPath() %>/consultaPropuesta"
                   style="padding: 10px 15px; background-color: #666; color: white; text-decoration: none; border-radius: 4px; display: flex; align-items: center;">
                    Limpiar
                </a>
            <% } %>
        </form>
    </div>

    <div class="Botones-Menu-Superior">
        <%
            Object usuarioObj = session.getAttribute("usuarioLogueado");
            if(usuarioObj != null) {
                DtUsuario usuario = (DtUsuario) usuarioObj;
        %>
            <div style="display:flex; align-items:center; gap:10px;">
               <%
                   String rutaImagen = usuario.getImagen();
                   if (rutaImagen == null || rutaImagen.isEmpty()) {
                       rutaImagen = request.getContextPath() + "/imagenes/usuarioDefault.png";
                   } else {
                       // Llamar al Web Service SOAP para obtener la imagen en Base64
                       ImagenWSEndpointService imagenServicio = new ImagenWSEndpointService();
                       IImagenControllerWS imagenWS = imagenServicio.getImagenWSEndpointPort();
                       rutaImagen = imagenWS.obtenerImagenBase64(rutaImagen);
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
        <% } else { %>
            <a href="altaPerfil">REGISTRARSE</a> |
            <a href="inicioDeSesion">ENTRAR</a>
        <% } %>
    </div>
</header>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const menuToggle = document.getElementById('menuToggle');
        const sidebarMenu = document.getElementById('sidebarMenu');
        const sidebarClose = document.getElementById('sidebarClose');
        const sidebarOverlay = document.getElementById('sidebarOverlay');

        function openMenu() {
            sidebarMenu.classList.add('active');
            sidebarOverlay.classList.add('active');
            menuToggle.style.display = 'none';
            document.body.style.overflow = 'hidden';
        }

        function closeMenu() {
            sidebarMenu.classList.remove('active');
            sidebarOverlay.classList.remove('active');
            menuToggle.style.display = '';
            document.body.style.overflow = '';
        }

        if (menuToggle) menuToggle.addEventListener('click', openMenu);
        if (sidebarClose) sidebarClose.addEventListener('click', closeMenu);
        if (sidebarOverlay) sidebarOverlay.addEventListener('click', closeMenu);

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && sidebarMenu.classList.contains('active')) {
                closeMenu();
            }
        });
    });
</script>
