<%@ page import="java.util.*, culturarte.logica.DTs.DTPropuesta, culturarte.logica.DTs.DTCategoria, culturarte.logica.DTs.DTUsuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Culturarte</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }

        body {
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #ddd;
        }

        .auth-buttons {
            display: flex;
            gap: 10px;
        }

        .auth-buttons a {
            text-decoration: none;
            color: #333;
            font-weight: bold;
            font-size: 14px;
        }

        .search-bar {
            margin: 20px 0;
            display: flex;
            gap: 10px;
        }

        .search-bar input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .search-bar button {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .filter-tabs {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .filter-tabs span {
            font-weight: bold;
            cursor: pointer;
            padding: 8px 16px;
            border-bottom: 2px solid transparent;
            border-radius: 4px 4px 0 0;
            transition: all 0.3s ease;
        }

        .filter-tabs span:hover {
            background-color: #f0f0f0;
            border-bottom: 2px solid #666;
        }

        .filter-tabs span.active {
            background-color: #333;
            color: white;
            border-bottom: 2px solid #333;
        }

        .gridPropuesta {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .cartaPropuesta {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .imagenPropuesta {
            height: 180px;
            background-color: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 14px;
        }

        .contenidoPropuesta {
            padding: 15px;
        }

        .tituloPropuesta {
            font-weight: bold;
            margin-bottom: 10px;
            font-size: 16px;
        }

        .descripcionPropuesta {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
            height: 60px;
            overflow: hidden;
        }

        .montoPropuesta {
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
        }

        .datosPropuesta {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }

        .botonDetalles {
            margin-top: 10px;
            text-align: center;
        }

        .botonDetalles .btn {
            width: 100%;
            padding: 8px 16px;
            font-size: 14px;
            font-weight: bold;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .botonDetalles .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }

        .categorias {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 20px;
        }

        .categorias h3 {
            margin-bottom: 15px;
            font-size: 18px;
        }

        .listaCategorias {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
        }

        .itemCategoria {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .itemCategoria input {
            margin-right: 5px;
        }

        @media (max-width: 768px) {
            .gridPropuesta {
                grid-template-columns: 1fr;
            }

            .listaCategorias {
                grid-template-columns: 1fr 1fr;
            }
        }

    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">
                <img src="imagenes/culturarte.png" alt="Logo Culturarte" style="width:150px; height:auto;">
            </div>
            <div class="auth-buttons">
                <a href="#">Tengo una Propuesta</a> | <a href="consultaPropuesta">Quiero ver Propuestas</a> | <a href="listarPropuestasParaComentar">Comentar Propuestas</a>
            </div>
            <div class="search-bar">
                <input type="text" placeholder="Título, descripción, lugar">
                <button>Buscar</button>
            </div>
             <div class="auth-buttons">
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
                                    <a href="#" style="text-decoration:none; color:#333;">Perfil</a> |
                                    <a href="${pageContext.request.contextPath}/cierreSesion" style="text-decoration:none; color:#333;">
                                        Cerrar Sesión
                                    </a>

                                </span>
                            </div>
                        </div>
                    <%}else{%>
                        <a href="altaPerfil">REGISTRARSE</a> | <a href="inicioDeSesion">ENTRAR</a>
                    <%}%>
                </div>
            </header>

        <div class="filter-tabs">
            <span class="estado-tab active" data-estado="todas">Propuestas Creadas</span>
            <span class="estado-tab" data-estado="en_financiacion">Propuestas en Financiación</span>
            <span class="estado-tab" data-estado="financiadas">Propuestas Financiadas</span>
            <span class="estado-tab" data-estado="no_financiadas">Propuestas NO Financiadas</span>
            <span class="estado-tab" data-estado="canceladas">Propuestas Canceladas</span>
        </div>

        <div class="gridPropuesta">
        <%List<DTPropuesta> propuestas = (List<DTPropuesta>) request.getAttribute("propuestas");
            if (propuestas != null) {
                for (DTPropuesta p : propuestas) {
                    String imagen = (p.getImagen() != null && !p.getImagen().isEmpty()) ? p.getImagen() : "imagenes/propuestaDefault.png";%>
            <div class="cartaPropuesta">
                <div class="imagenPropuesta">
                    <img src="<%= imagen %>" alt="Imagen de <%= p.getTitulo() %>" style="width:100%; height:180px; object-fit:cover;"></div>
                    <div class="contenidoPropuesta">
                        <div class="tituloPropuesta"><%= p.getTitulo() %></div>
                            <div class="descripcionPropuesta"><%= p.getDescripcion() %></div>
                                <div class="montoPropuesta"><%= p.getMontoNecesario() %> UYU</div>
                                    <div class="datosPropuesta">
                                        <div><%= p.getEstadoActual() %></div>
                                        <div><%= p.getFechaPublicacion() %></div>
                                    </div>
                                    <div class="botonDetalles">
                                        <a href="<%= request.getContextPath() %>/consultaPropuesta?accion=detalle&titulo=<%= 
                                            java.net.URLEncoder.encode(p.getTitulo(), "UTF-8") %>" 
                                           class="btn btn-primary">
                                            Ver Detalles
                                        </a>
                                    </div>
                                </div>
                            </div>
                        <%}}%>
                    </div>

            <div class="categorias">
                <h3>CATEGORÍAS</h3>
                <form id="filtroCategorias" method="post" action="consultaPropuestaPorCategoria">
                   <div class="listaCategorias">
                        <%List<DTCategoria> categorias = (List<DTCategoria>) request.getAttribute("categorias");
                       String[] categoriasSeleccionadas = (String[]) request.getAttribute("categoriasSeleccionadas");
                        if (categorias != null) {
                            for (DTCategoria categ : categorias) {
                                boolean estaSeleccionada = false;
                                if (categoriasSeleccionadas != null) {
                                    for (String catSel : categoriasSeleccionadas) {
                                        if (catSel.equals(categ.getNombre())) {
                                            estaSeleccionada = true;
                                            break;
                                        }
                                    }
                                }%>
                           <div class="itemCategoria">
                               <input type="checkbox" id="<%= categ.getNombre() %>" name="categoria" value="<%= categ.getNombre() %>">
                               <label for="<%= categ.getNombre() %>"><%= categ.getNombre() %></label>
                           </div>
                       <%}}%>
                   </div>
                   <div style="margin-top: 15px;">
                       <button type="submit" style="background-color: #333; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;">
                           Filtrar por Categorías
                       </button>
                       <button type="button" onclick="limpiarFiltros()" style="background-color: #666; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-left: 10px;">
                           Limpiar Filtros
                       </button>
                   </div>
                </form>
               </div>
           </div>

    <script>
        // Manejar clicks en los tabs de estado
        document.querySelectorAll('.estado-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                // Remover clase active de todos los tabs
                document.querySelectorAll('.estado-tab').forEach(t => {
                    t.classList.remove('active');
                });
                // Agregar clase active al tab clickeado
                this.classList.add('active');
                
                // Obtener el estado del tab clickeado
                const estado = this.getAttribute('data-estado');
                
                // Redirigir con el parámetro de estado
                const url = new URL(window.location);
                url.searchParams.set('estado', estado);
                window.location.href = url.toString();
            });
        });
        
        // Marcar el tab activo según el estado actual
        const estadoFiltro = '<%= request.getAttribute("estadoFiltro") %>';
        if (estadoFiltro && estadoFiltro !== 'null') {
            document.querySelectorAll('.estado-tab').forEach(tab => {
                tab.classList.remove('active');
                if (tab.getAttribute('data-estado') === estadoFiltro) {
                    tab.classList.add('active');
                }
            });
        }
        
        function limpiarFiltros() {
            document.querySelectorAll('input[name="categoria"]').forEach(checkbox => {
                checkbox.checked = false;
            });
            document.getElementById('filtroCategorias').submit();
        }

        document.querySelectorAll('input[name="categoria"]').forEach(checkbox => {
            checkbox.addEventListener('change', function() {
            });
        });
    </script>
</body>
</html>
</html>