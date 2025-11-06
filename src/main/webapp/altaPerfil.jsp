<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registro - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        .form-control.is-valid {
            border-color: #28a745;
            padding-right: calc(1.5em + 0.75rem);
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 8 8'%3e%3cpath fill='%2328a745' d='M2.3 6.73L.6 4.53c-.4-1.04.46-1.4 1.1-.8l1.1 1.4 3.4-3.8c.6-.63 1.6-.27 1.2.7l-4 4.6c-.43.5-.8.4-1.1.1z'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }
        .form-control.is-invalid {
            border-color: #dc3545;
            padding-right: calc(1.5em + 0.75rem);
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }
        .invalid-feedback {
            display: none;
            width: 100%;
            margin-top: 0.25rem;
            font-size: 0.875em;
            color: #dc3545;
        }
        .invalid-feedback[style*="display: block"] {
            display: block !important;
        }
        .form-check-input.is-valid {
            border-color: #28a745;
        }
        .form-check-input.is-invalid {
            border-color: #dc3545;
        }
    </style>
</head>
<body class="bg-light">
<div class="container">
    <jsp:include page="cabezalComun.jsp"/>
</div>
<div class="container d-flex justify-content-center py-5">
    <div class="card shadow-sm p-4" style="width: 450px;">
        <h3 class="text-center mb-3">Registro</h3>

        <form method="post" action="<%= request.getContextPath() %>/altaPerfil" enctype="multipart/form-data" id="formAltaPerfil" novalidate>
            <div class="mb-3">
                <label class="form-label">Nickname</label>
                <input type="text" name="nickname" id="nickname" class="form-control"
                       value="<%= request.getAttribute("nickname") != null ? request.getAttribute("nickname") : "" %>"
                       placeholder="Ingrese su nickname" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Nombre</label>
                <input type="text" name="nombre" id="nombre" class="form-control"
                       value="<%= request.getAttribute("nombre") != null ? request.getAttribute("nombre") : "" %>"
                       placeholder="Ingrese su nombre" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Apellido</label>
                <input type="text" name="apellido" id="apellido" class="form-control"
                       value="<%= request.getAttribute("apellido") != null ? request.getAttribute("apellido") : "" %>"
                       placeholder="Ingrese su apellido" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" id="password" class="form-control" 
                       placeholder="Ingrese su contraseña" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Confirmar Contraseña</label>
                <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" 
                       placeholder="Confirme su contraseña" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Correo Electrónico</label>
                <input type="email" name="email" id="email" class="form-control"
                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
                       placeholder="ejemplo@correo.com" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Fecha de Nacimiento</label>
                <input type="date" name="fechaNacimiento" id="fechaNacimiento" class="form-control"
                       value="<%= request.getAttribute("fechaNacimiento") != null ? request.getAttribute("fechaNacimiento") : "" %>" required>
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Imagen (opcional)</label>
                <input type="file" name="imagen" id="imagen" class="form-control" accept="image/*">
                <div class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Tipo de Usuario</label>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="tipoUsuario" value="PROPONENTE"
                           id="proponente"
                           <%= "PROPONENTE".equals(request.getAttribute("tipoUsuario")) ? "checked" : "" %> required>
                    <label class="form-check-label" for="proponente">Proponente</label>
                </div>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="tipoUsuario" value="COLABORADOR"
                           id="colaborador"
                           <%= "COLABORADOR".equals(request.getAttribute("tipoUsuario")) ? "checked" : "" %> required>
                    <label class="form-check-label" for="colaborador">Colaborador</label>
                </div>
                <div class="invalid-feedback" style="display: block;"></div>
            </div>

            <div id="proponenteFields" style="display:none;">
                <div class="mb-3">
                    <label class="form-label">Dirección</label>
                    <input type="text" name="direccion" id="direccion" class="form-control"
                           value="<%= request.getAttribute("direccion") != null ? request.getAttribute("direccion") : "" %>"
                           placeholder="Ingrese su dirección">
                    <div class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Biografía</label>
                    <textarea name="biografia" id="biografia" class="form-control" rows="3"
                              placeholder="Una breve descripción sobre usted..."><%=
                                  request.getAttribute("biografia") != null ? request.getAttribute("biografia") : ""
                              %></textarea>
                </div>

                <div class="mb-3">
                    <label class="form-label">Sitio Web</label>
                    <input type="text" name="sitioWeb" id="sitioWeb" class="form-control"
                           value="<%= request.getAttribute("sitioWeb") != null ? request.getAttribute("sitioWeb") : "" %>"
                           placeholder="https://www.misitio.com">
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100" id="submitBtn">Crear Usuario</button>
             <a href="<%= request.getContextPath() %>/principal" class="btn btn-outline-secondary w-100 mt-2">
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
    document.addEventListener('DOMContentLoaded', function() {
        const tipoUsuarioRadios = document.querySelectorAll('input[name="tipoUsuario"]');
        const proponenteFields = document.getElementById('proponenteFields');
        const form = document.getElementById('formAltaPerfil');

        // Mostrar/ocultar campos de proponente
        tipoUsuarioRadios.forEach(radio => {
            radio.addEventListener('change', function() {
                if (this.value === 'PROPONENTE') {
                    proponenteFields.style.display = 'block';
                    validateDireccion();
                } else {
                    proponenteFields.style.display = 'none';
                    const direccionInput = document.getElementById('direccion');
                    if (direccionInput) {
                        direccionInput.classList.remove('is-invalid', 'is-valid');
                        const feedback = direccionInput.parentElement.querySelector('.invalid-feedback');
                        if (feedback) feedback.textContent = '';
                    }
                }
                validateTipoUsuario();
            });
        });
        if (document.querySelector('input[name="tipoUsuario"][value="PROPONENTE"]')?.checked)
            proponenteFields.style.display = 'block';

        // Funciones de validación
        function showError(input, message) {
            input.classList.remove('is-valid');
            input.classList.add('is-invalid');
            const feedback = input.parentElement.querySelector('.invalid-feedback');
            if (feedback) {
                feedback.textContent = message;
                feedback.style.display = 'block';
            }
        }

        function showSuccess(input) {
            input.classList.remove('is-invalid');
            input.classList.add('is-valid');
            const feedback = input.parentElement.querySelector('.invalid-feedback');
            if (feedback) {
                feedback.textContent = '';
                feedback.style.display = 'none';
            }
        }

        function validateNickname() {
            const input = document.getElementById('nickname');
            const value = input.value.trim();
            if (value === '') {
                showError(input, 'El nickname es obligatorio');
                return false;
            }
            showSuccess(input);
            return true;
        }

        function validateNombre() {
            const input = document.getElementById('nombre');
            const value = input.value.trim();
            if (value === '') {
                showError(input, 'El nombre es obligatorio');
                return false;
            }
            showSuccess(input);
            return true;
        }

        function validateApellido() {
            const input = document.getElementById('apellido');
            const value = input.value.trim();
            if (value === '') {
                showError(input, 'El apellido es obligatorio');
                return false;
            }
            showSuccess(input);
            return true;
        }

        function validatePassword() {
            const input = document.getElementById('password');
            const value = input.value.trim();
            if (value === '') {
                showError(input, 'La contraseña es obligatoria');
                return false;
            }
            showSuccess(input);
            // Validar también la confirmación cuando cambia la contraseña
            validateConfirmPassword();
            return true;
        }

        function validateConfirmPassword() {
            const input = document.getElementById('confirmPassword');
            const password = document.getElementById('password').value.trim();
            const value = input.value.trim();
            
            if (value === '') {
                showError(input, 'Debe confirmar la contraseña');
                return false;
            }
            if (value !== password) {
                showError(input, 'Las contraseñas no coinciden');
                return false;
            }
            showSuccess(input);
            return true;
        }

        function validateEmail() {
            const input = document.getElementById('email');
            const value = input.value.trim();
            const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
            
            if (value === '') {
                showError(input, 'El correo electrónico es obligatorio');
                return false;
            }
            if (!emailRegex.test(value)) {
                showError(input, 'Formato de correo electrónico inválido');
                return false;
            }
            showSuccess(input);
            return true;
        }

        function validateFechaNacimiento() {
            const input = document.getElementById('fechaNacimiento');
            const value = input.value.trim();
            
            if (value === '') {
                showError(input, 'La fecha de nacimiento es obligatoria');
                return false;
            }
            
            try {
                const fechaNac = new Date(value);
                const hoy = new Date();
                hoy.setHours(0, 0, 0, 0);
                
                if (fechaNac > hoy) {
                    showError(input, 'La fecha de nacimiento no puede ser futura');
                    return false;
                }
                
                const fechaLimite = new Date();
                fechaLimite.setFullYear(fechaLimite.getFullYear() - 120);
                if (fechaNac < fechaLimite) {
                    showError(input, 'La fecha de nacimiento no puede ser anterior a hace 120 años');
                    return false;
                }
            } catch (e) {
                showError(input, 'Formato de fecha inválido');
                return false;
            }
            
            showSuccess(input);
            return true;
        }

        function validateTipoUsuario() {
            const radios = document.querySelectorAll('input[name="tipoUsuario"]');
            const selected = Array.from(radios).find(r => r.checked);
            const feedback = document.querySelector('input[name="tipoUsuario"]').closest('.mb-3').querySelector('.invalid-feedback');
            
            if (!selected) {
                radios.forEach(r => r.classList.add('is-invalid'));
                if (feedback) {
                    feedback.textContent = 'Debe seleccionar un tipo de usuario';
                    feedback.style.display = 'block';
                }
                return false;
            }
            
            radios.forEach(r => {
                r.classList.remove('is-invalid');
                r.classList.add('is-valid');
            });
            if (feedback) {
                feedback.textContent = '';
                feedback.style.display = 'none';
            }
            return true;
        }

        function validateDireccion() {
            const input = document.getElementById('direccion');
            if (!input) return true;
            
            const tipoUsuario = document.querySelector('input[name="tipoUsuario"]:checked')?.value;
            if (tipoUsuario !== 'PROPONENTE') return true;
            
            const value = input.value.trim();
            if (value === '') {
                showError(input, 'La dirección es obligatoria para Proponentes');
                return false;
            }
            showSuccess(input);
            return true;
        }

        // Validación en tiempo real
        document.getElementById('nickname').addEventListener('blur', validateNickname);
        document.getElementById('nickname').addEventListener('input', function() {
            if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                validateNickname();
            }
        });

        document.getElementById('nombre').addEventListener('blur', validateNombre);
        document.getElementById('nombre').addEventListener('input', function() {
            if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                validateNombre();
            }
        });

        document.getElementById('apellido').addEventListener('blur', validateApellido);
        document.getElementById('apellido').addEventListener('input', function() {
            if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                validateApellido();
            }
        });

        document.getElementById('password').addEventListener('blur', validatePassword);
        document.getElementById('password').addEventListener('input', function() {
            if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                validatePassword();
            }
        });

        document.getElementById('confirmPassword').addEventListener('blur', validateConfirmPassword);
        document.getElementById('confirmPassword').addEventListener('input', function() {
            if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                validateConfirmPassword();
            }
        });

        document.getElementById('email').addEventListener('blur', validateEmail);
        document.getElementById('email').addEventListener('input', function() {
            if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                validateEmail();
            }
        });

        document.getElementById('fechaNacimiento').addEventListener('change', validateFechaNacimiento);
        document.getElementById('fechaNacimiento').addEventListener('blur', validateFechaNacimiento);

        tipoUsuarioRadios.forEach(radio => {
            radio.addEventListener('change', validateTipoUsuario);
        });

        const direccionInput = document.getElementById('direccion');
        if (direccionInput) {
            direccionInput.addEventListener('blur', validateDireccion);
            direccionInput.addEventListener('input', function() {
                if (this.classList.contains('is-invalid') || this.classList.contains('is-valid')) {
                    validateDireccion();
                }
            });
        }

        // Validar antes de enviar
        form.addEventListener('submit', function(e) {
            const isValid = 
                validateNickname() &&
                validateNombre() &&
                validateApellido() &&
                validatePassword() &&
                validateConfirmPassword() &&
                validateEmail() &&
                validateFechaNacimiento() &&
                validateTipoUsuario() &&
                validateDireccion();

            if (!isValid) {
                e.preventDefault();
                e.stopPropagation();
                // Mostrar mensaje general
                const firstError = form.querySelector('.is-invalid');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    firstError.focus();
                }
            }
        });
    });
</script>
</body>
</html>
