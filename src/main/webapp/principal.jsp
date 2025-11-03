<%@ page import="java.util.*, culturarte.servicios.cliente.propuestas.DtPropuesta, culturarte.servicios.cliente.propuestas.DtCategoria, culturarte.servicios.cliente.propuestas.DtUsuario, com.culturarteWeb.util.WSFechaPropuesta" %>
<%--
    Quitamos la importación de 'PropuestaConDatos' para evitar problemas de visibilidad
    si es una clase interna no pública.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Culturarte</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <jsp:include page="estiloCabezalComun.jsp"/>

    <style>
        /* --- Estilos Globales --- */
        body {
            background-color: #f5f5f5;
            color: #333;
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
        }

        /* --- Estilos para las Pestañas de Filtro (Tabs) --- */
        .nav-link.estado-tab {
            cursor: pointer;
            color: #333; /* Color inactivo */
        }
        .nav-link.estado-tab:hover {
            color: #000;
        }
        .nav-link.estado-tab.active {
            font-weight: bold;
            background-color: #333;
            color: white;
            border-color: #333 #333 #f5f5f5;
        }

        /* --- Estilos de las Tarjetas de Propuesta --- */
        .cartaPropuesta {
            display: flex;
            flex-direction: column;
            border-radius: 8px;
            background-color: white;
            overflow: hidden;
        }

        .imagenPropuesta {
            height: 180px;
            width: 100%;
            object-fit: cover;
        }

        .contenidoPropuesta {
            padding: 1.25rem;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        .tituloPropuesta {
            font-weight: bold;
            margin-bottom: 10px;
            font-size: 1.1rem;
        }

        .descripcionPropuesta {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
            height: 60px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
        }

        .progreso-financiacion {
            margin-bottom: 15px;
        }

        .info-progreso {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }

        .estadisticas-propuesta {
            font-size: 12px;
            color: #666;
            margin-bottom: 15px;
        }

        .icono {
            font-size: 14px;
            margin-right: 5px;
        }

        .datosPropuesta {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }

        .contenidoPropuesta .btn {
            margin-top: auto;
        }

        /* --- Estilos de las Categorías --- */
        .categorias {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
        }

        .itemCategoria {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        @media (max-width: 576px) {
            .estadisticas-propuesta {
                flex-direction: column;
                gap: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="container my-4">

        <jsp:include page="cabezalComun.jsp"/>

        <% String busquedaActual = (String) request.getAttribute("busqueda"); %>
        <% if (busquedaActual != null && !busquedaActual.isEmpty()) { %>
            <div class="alert alert-info d-flex flex-column flex-sm-row justify-content-sm-between align-items-sm-center shadow-sm">
                <div>
                    <strong>🔍 Búsqueda activa:</strong> "<%= busquedaActual %>"
                    <br>
                    <small>
                        <%-- Usamos el nombre completo de la clase aquí por seguridad --%>
                        Mostrando <%= ((List<com.culturarteWeb.servlets.PrincipalServlet.PropuestaConDatos>) request.getAttribute("propuestas")).size() %> resultado(s)
                    </small>
                </div>
                <a href="<%= request.getContextPath() %>/principal"
                   class="btn btn-sm btn-outline-danger mt-2 mt-sm-0">
                    ✕ Limpiar búsqueda
                </a>
            </div>
        <% } %>

        <ul class="nav nav-tabs mb-4">
            <li class="nav-item">
                <span class="nav-link estado-tab active" data-estado="todas">Propuestas Creadas</span>
            </li>
            <li class="nav-item">
                <span class="nav-link estado-tab" data-estado="en_financiacion">En Financiación</span>
            </li>
            <li class="nav-item">
                <span class="nav-link estado-tab" data-estado="financiadas">Financiadas</span>
            </li>
            <li class="nav-item">
                <span class="nav-link estado-tab" data-estado="no_financiadas">NO Financiadas</span>
            </li>
            <li class="nav-item">
                <span class="nav-link estado-tab" data-estado="canceladas">Canceladas</span>
            </li>
        </ul>

        <div class="row g-4 mb-4">
            <%
                // CORRECCIÓN: Usamos el nombre de clase completo para la lista y el cast.
                List<com.culturarteWeb.servlets.PrincipalServlet.PropuestaConDatos> propuestas =
                    (List<com.culturarteWeb.servlets.PrincipalServlet.PropuestaConDatos>) request.getAttribute("propuestas");

                if (propuestas != null && !propuestas.isEmpty()) {
                    // CORRECCIÓN: Usamos el nombre de clase completo en el bucle 'for'.
                    for (com.culturarteWeb.servlets.PrincipalServlet.PropuestaConDatos propuestaConDatos : propuestas) {
                        DtPropuesta p = propuestaConDatos.getPropuesta();
                        String imagen = (p.getImagen() != null && !p.getImagen().isEmpty()) ? p.getImagen() : "imagenes/propuestaDefault.png";
                        double porcentajeProgreso = p.getMontoNecesario() > 0 ? (propuestaConDatos.getMontoRecaudado() / p.getMontoNecesario()) * 100 : 0;
                        if (porcentajeProgreso > 100) porcentajeProgreso = 100;

                        long porcentajeRedondeado = Math.round(porcentajeProgreso);
            %>
            <div class="col-12 col-md-6 col-lg-4 d-flex">
                <div class="cartaPropuesta h-100 shadow-sm w-100">
                    <img src="<%= imagen %>" class="imagenPropuesta" alt="Imagen de <%= p.getTitulo() %>">

                    <div class="contenidoPropuesta">
                        <div class="tituloPropuesta"><%= p.getTitulo() %></div>
                        <div class="descripcionPropuesta"><%= p.getDescripcion() %></div>

                        <div class="progreso-financiacion">
                            <div class="info-progreso">
                                <span>$<%= String.format("%.0f", propuestaConDatos.getMontoRecaudado()) %> recaudado</span>
                                <span><%= porcentajeRedondeado %>%</span>
                            </div>

                            <div class="progress" style="height: 8px;">
                                <div class="progress-bar bg-success" role="progressbar"
                                     style="width: <%= porcentajeRedondeado %>%;"
                                     aria-valuenow="<%= porcentajeRedondeado %>"
                                     aria-valuemin="0" <%-- CORRECCIÓN: Era "E" ahora es "0" --%>
                                     aria-valuemax="100"></div>
                            </div>
                        </div>

                        <div class="estadisticas-propuesta d-flex flex-column flex-sm-row justify-content-sm-between">
                            <div class="dias-restantes">
                                <span class="icono">⏰</span>
                                <span><%= propuestaConDatos.getDiasRestantes() %> días restantes</span>
                            </div>
                            <div class="colaboradores-count">
                                <span class="icono">👥</span>
                                <span><%= propuestaConDatos.getTotalColaboradores() %> colaboradores</span>
                            </div>
                        </div>

                        <div class="datosPropuesta d-flex justify-content-between">
                            <span><%= p.getEstadoActual() %></span>
                            <span><% 
                                if (p.getFechaPublicacion() != null) {
                                    java.time.LocalDate fechaPublicacion = WSFechaPropuesta.toJavaLocalDate(p.getFechaPublicacion());
                                    out.print(fechaPublicacion != null ? fechaPublicacion.toString() : "N/A");
                                } else {
                                    out.print("N/A");
                                }
                            %></span>
                        </div>

                        <a href="<%= request.getContextPath() %>/consultaPropuesta?accion=detalle&titulo=<%=
                                java.net.URLEncoder.encode(p.getTitulo(), "UTF-8") %>"
                           class="btn btn-primary w-100">
                            Ver Detalles
                        </a>
                    </div>
                </div>
            </div>
            <%
                    } // Fin del for
                } else { // Si no hay propuestas
            %>
                <div class="col-12">
                    <div class="alert alert-warning text-center">
                        No se encontraron propuestas que coincidan con los filtros seleccionados.
                    </div>
                </div>
            <%
                } // Fin del if (propuestas != null)
            %>
        </div> <div class="categorias shadow-sm mb-4">
            <h3>CATEGORÍAS</h3>
            <form id="filtroCategorias" method="post" action="consultaPropuestaPorCategoria">

                <div class="row g-3">
                    <%
                        List<DtCategoria> categorias = (List<DtCategoria>) request.getAttribute("categorias");
                        String[] categoriasSeleccionadas = (String[]) request.getAttribute("categoriasSeleccionadas");

                        if (categorias != null) {
                            for (DtCategoria categ : categorias) {
                                boolean estaSeleccionada = false;
                                if (categoriasSeleccionadas != null) {
                                    for (String catSel : categoriasSeleccionadas) {
                                        if (catSel.equals(categ.getNombre())) {
                                            estaSeleccionada = true;
                                            break;
                                        }
                                    }
                                }
                    %>
                    <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                        <div class="form-check itemCategoria">
                            <input class="form-check-input" type="checkbox"
                                   id="<%= categ.getNombre() %>"
                                   name="categoria"
                                   value="<%= categ.getNombre() %>"
                                   <%= estaSeleccionada ? "checked" : "" %>>
                            <label class="form-check-label" for="<%= categ.getNombre() %>">
                                <%= categ.getNombre() %>
                            </label>
                        </div>
                    </div>
                    <%
                            } // Fin del for
                        } // Fin del if (categorias != null)
                    %>
                </div> <div class="mt-4">
                    <button type="submit" class="btn btn-dark">
                        Filtrar por Categorías
                    </button>
                    <button type="button" onclick="limpiarFiltros()" class="btn btn-outline-secondary ms-2">
                        Limpiar Filtros
                    </button>
                </div>
            </form>
        </div>

    </div> <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelectorAll('.estado-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                document.querySelectorAll('.estado-tab').forEach(t => {
                    t.classList.remove('active');
                });
                this.classList.add('active');

                const estado = this.getAttribute('data-estado');
                const url = new URL(window.location.origin + window.location.pathname);

                url.searchParams.set('estado', estado);

                const busquedaActual = '<%= busquedaActual != null ? busquedaActual : "" %>';
                if (busquedaActual) {
                    url.searchParams.set('busqueda', busquedaActual);
                }

                window.location.href = url.toString();
            });
        });

        const estadoFiltro = '<%= request.getAttribute("estadoFiltro") %>';
        if (estadoFiltro && estadoFiltro !== 'null') {
            document.querySelectorAll('.estado-tab').forEach(tab => {
                tab.classList.remove('active');
                if (tab.getAttribute('data-estado') === estadoFiltro) {
                    tab.classList.add('active');
                }
            });
        } else {
            const primerTab = document.querySelector('.estado-tab[data-estado="todas"]');
            if (!document.querySelector('.estado-tab.active') && primerTab) {
                primerTab.classList.add('active');
            }
        }

        function limpiarFiltros() {
            document.querySelectorAll('input[name="categoria"]').forEach(checkbox => {
                checkbox.checked = false;
            });
            document.getElementById('filtroCategorias').submit();
        }
    </script>
</body>
</html>