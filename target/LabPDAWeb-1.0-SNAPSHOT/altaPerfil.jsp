<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registro - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container d-flex justify-content-center py-5">
    <div class="card shadow-sm p-4" style="width: 450px;">
        <h3 class="text-center mb-3">Registro</h3>

        <form method="post" action="<%= request.getContextPath() %>/altaPerfil" enctype="multipart/form-data">
            <div class="mb-3">
                <label class="form-label">Nickname</label>
                <input type="text" name="nickname" class="form-control" placeholder="Ingrese su nickname">
            </div>

            <div class="mb-3">
                <label class="form-label">Nombre</label>
                <input type="text" name="nombre" class="form-control" placeholder="Ingrese su nombre">
            </div>

            <div class="mb-3">
                <label class="form-label">Apellido</label>
                <input type="text" name="apellido" class="form-control" placeholder="Ingrese su apellido">
            </div>

            <div class="mb-3">
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" class="form-control" placeholder="Ingrese su contraseña">
            </div>

            <div class="mb-3">
                <label class="form-label">Confirmar Contraseña</label>
                <input type="password" name="confirmPassword" class="form-control" placeholder="Confirme su contraseña">
            </div>

            <div class="mb-3">
                <label class="form-label">Correo Electrónico</label>
                <input type="email" name="email" class="form-control" placeholder="ejemplo@correo.com">
            </div>

            <div class="mb-3">
                <label class="form-label">Fecha de Nacimiento</label>
                <input type="date" name="fechaNacimiento" class="form-control">
            </div>

            <div class="mb-3">
                <label class="form-label">Imagen (opcional)</label>
                <input type="file" name="imagen" class="form-control" accept="image/*">
            </div>

            <div class="mb-3">
                <label class="form-label">Tipo de Usuario</label>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="tipoUsuario" value="PROPONENTE" id="proponente">
                    <label class="form-check-label" for="proponente">Proponente</label>
                </div>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="tipoUsuario" value="COLABORADOR" id="colaborador">
                    <label class="form-check-label" for="colaborador">Colaborador</label>
                </div>
            </div>

            <div id="proponenteFields" style="display:none;">
                <div class="mb-3">
                    <label class="form-label">Dirección</label>
                    <input type="text" name="direccion" class="form-control" placeholder="Ingrese su dirección">
                </div>

                <div class="mb-3">
                    <label class="form-label">Biografía</label>
                    <textarea name="biografia" class="form-control" rows="3" placeholder="Una breve descripción sobre usted..."></textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label">Sitio Web</label>
                    <input type="text" name="sitioWeb" class="form-control" placeholder="https://www.misitio.com">
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100">Crear Usuario</button>
             <a href="<%= request.getContextPath() %>/principal.jsp" class="btn btn-outline-secondary">
                                        Ir al Inicio
                                    </a>
        </form>

        <%String error = (String) request.getAttribute("error");
         if (error != null && !error.isEmpty()) {%>
            <div class="alert alert-danger mt-3" role="alert">
                <%=error%>
            </div>
        <%}%>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Mostrar/ocultar campos de Proponente
    document.addEventListener('DOMContentLoaded', function() {
        const tipoUsuarioRadios = document.querySelectorAll('input[name="tipoUsuario"]');
        const proponenteFields = document.getElementById('proponenteFields');
        
        tipoUsuarioRadios.forEach(radio => {
            radio.addEventListener('change', function() {
                if (this.value === 'PROPONENTE') {
                    proponenteFields.style.display = 'block';
                } else {
                    proponenteFields.style.display = 'none';
                }
            });
        });
    });
</script>
</body>
</html>
