<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="culturarte.servicios.cliente.usuario.DtUsuario" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Baja de Proponente - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        .warning-box {
            background-color: #fff3cd;
            border: 2px solid #ffc107;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .danger-text {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>

        <div class="py-5">
            <div class="row justify-content-center">
                <div class="col-md-8 col-12">
                    <div class="card shadow-sm">
                        <div class="card-header bg-danger text-white">
                            <h3 class="text-center mb-0">
                                <i class="bi bi-exclamation-triangle"></i> Baja de Proponente
                            </h3>
                        </div>
                        <div class="card-body">

                            <% if (request.getAttribute("error") != null) { %>
                                <div class="alert alert-danger" role="alert">
                                    <%= request.getAttribute("error") %>
                                </div>
                            <% } %>

                            <div class="warning-box">
                                <h5 class="danger-text">⚠️ ADVERTENCIA: Esta acción es irreversible</h5>
                                <p class="mt-3">Al darte de baja como proponente, se eliminará permanentemente:</p>
                                <ul>
                                    <li>Todos tus datos personales</li>
                                    <li>Todas las propuestas que hayas creado</li>
                                    <li>Todas las colaboraciones asociadas a tus propuestas</li>
                                    <li>Todas las relaciones de seguimiento (seguidos y seguidores)</li>
                                    <li>Los favoritos de otros usuarios que incluyan tus propuestas</li>
                                </ul>
                                <p class="danger-text mt-3">Esta operación NO puede deshacerse.</p>
                            </div>

                            <form method="post" action="<%= request.getContextPath() %>/bajaProponente" id="formBaja">
                                <div class="mb-4">
                                    <label class="form-label">
                                        Para confirmar la eliminación de tu cuenta, escribe <strong>CONFIRMAR</strong> en el campo siguiente:
                                    </label>
                                    <input type="text"
                                           name="confirmacion"
                                           id="confirmacion"
                                           class="form-control"
                                           placeholder="Escribe CONFIRMAR"
                                           required>
                                </div>

                                <div class="d-flex gap-3 justify-content-center flex-wrap">
                                    <a href="<%= request.getContextPath() %>/principal"
                                       class="btn btn-secondary btn-lg">
                                        <i class="bi bi-arrow-left"></i> Cancelar
                                    </a>
                                    <button type="submit"
                                            class="btn btn-danger btn-lg"
                                            id="btnEliminar"
                                            disabled>
                                        <i class="bi bi-trash"></i> Eliminar Mi Cuenta
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('confirmacion').addEventListener('input', function() {
            const btnEliminar = document.getElementById('btnEliminar');
            btnEliminar.disabled = this.value !== 'CONFIRMAR';
        });

        document.getElementById('formBaja').addEventListener('submit', function(e) {
            if (!confirm('¿Estás totalmente seguro de que deseas eliminar tu cuenta? Esta acción NO puede deshacerse.')) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>
