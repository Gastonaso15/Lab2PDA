<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alta de Perfil - Culturarte</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            margin: 0;
            font-size: 2.5em;
            font-weight: 300;
        }
        
        .form-container {
            padding: 40px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .form-row .form-group {
            flex: 1;
            margin-bottom: 0;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        
        input[type="text"], input[type="email"], input[type="password"], 
        input[type="date"], select, textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s ease;
            box-sizing: border-box;
        }
        
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #4facfe;
            box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.1);
        }
        
        textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .radio-group {
            display: flex;
            gap: 30px;
            margin-top: 10px;
        }
        
        .radio-option {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .radio-option input[type="radio"] {
            width: auto;
            margin: 0;
        }
        
        .proponente-fields {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-top: 15px;
            border-left: 4px solid #4facfe;
        }
        
        .file-input-wrapper {
            position: relative;
            display: inline-block;
            cursor: pointer;
            width: 100%;
        }
        
        .file-input {
            position: absolute;
            left: -9999px;
        }
        
        .file-input-label {
            display: block;
            padding: 12px 15px;
            border: 2px dashed #e1e5e9;
            border-radius: 8px;
            text-align: center;
            background: #f8f9fa;
            transition: all 0.3s ease;
        }
        
        .file-input-label:hover {
            border-color: #4facfe;
            background: #e3f2fd;
        }
        
        .btn {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            border: none;
            padding: 15px 30px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            text-decoration: none;
            display: inline-block;
            margin-right: 15px;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(79, 172, 254, 0.4);
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
        }
        
        .btn-secondary:hover {
            box-shadow: 0 5px 15px rgba(108, 117, 125, 0.4);
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #dc3545;
        }
        
        .required {
            color: #dc3545;
        }
        
        .form-actions {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e1e5e9;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Alta de Perfil</h1>
            <p>Registra un nuevo usuario en el sistema</p>
        </div>
        
        <div class="form-container">
            <c:if test="${not empty error}">
                <div class="error-message">
                    <strong>Error:</strong> ${error}
                </div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/altaPerfil" method="post" enctype="multipart/form-data">
                
                <!-- Información básica -->
                <h3>Información Personal</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="nickname">Nickname <span class="required">*</span></label>
                        <input type="text" id="nickname" name="nickname" required 
                               value="${param.nickname}" placeholder="Ingrese su nickname">
                    </div>
                    <div class="form-group">
                        <label for="email">Correo Electrónico <span class="required">*</span></label>
                        <input type="email" id="email" name="email" required 
                               value="${param.email}" placeholder="ejemplo@correo.com">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="nombre">Nombre <span class="required">*</span></label>
                        <input type="text" id="nombre" name="nombre" required 
                               value="${param.nombre}" placeholder="Su nombre">
                    </div>
                    <div class="form-group">
                        <label for="apellido">Apellido <span class="required">*</span></label>
                        <input type="text" id="apellido" name="apellido" required 
                               value="${param.apellido}" placeholder="Su apellido">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Contraseña <span class="required">*</span></label>
                        <input type="password" id="password" name="password" required 
                               placeholder="Mínimo 6 caracteres">
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">Confirmar Contraseña <span class="required">*</span></label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required 
                               placeholder="Repita su contraseña">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="fechaNacimiento">Fecha de Nacimiento <span class="required">*</span></label>
                        <input type="date" id="fechaNacimiento" name="fechaNacimiento" required 
                               value="${param.fechaNacimiento}">
                    </div>
                    <div class="form-group">
                        <label for="imagen">Imagen de Perfil (opcional)</label>
                        <div class="file-input-wrapper">
                            <input type="file" id="imagen" name="imagen" accept="image/*" class="file-input">
                            <label for="imagen" class="file-input-label">
                                📷 Seleccionar imagen
                            </label>
                        </div>
                    </div>
                </div>
                
                <!-- Tipo de usuario -->
                <div class="form-group">
                    <label>Tipo de Usuario <span class="required">*</span></label>
                    <div class="radio-group">
                        <div class="radio-option">
                            <input type="radio" id="proponente" name="tipoUsuario" value="PROPONENTE" 
                                   ${param.tipoUsuario == 'PROPONENTE' ? 'checked' : ''}>
                            <label for="proponente">Proponente</label>
                        </div>
                        <div class="radio-option">
                            <input type="radio" id="colaborador" name="tipoUsuario" value="COLABORADOR" 
                                   ${param.tipoUsuario == 'COLABORADOR' ? 'checked' : ''}>
                            <label for="colaborador">Colaborador</label>
                        </div>
                    </div>
                </div>
                
                <!-- Campos específicos de Proponente -->
                <div id="proponenteFields" class="proponente-fields" style="display: none;">
                    <h4>Información de Proponente</h4>
                    
                    <div class="form-group">
                        <label for="direccion">Dirección <span class="required">*</span></label>
                        <input type="text" id="direccion" name="direccion" 
                               value="${param.direccion}" placeholder="Su dirección completa">
                    </div>
                    
                    <div class="form-group">
                        <label for="biografia">Biografía</label>
                        <textarea id="biografia" name="biografia" 
                                  placeholder="Una breve descripción sobre usted...">${param.biografia}</textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="sitioWeb">Sitio Web</label>
                        <input type="text" id="sitioWeb" name="sitioWeb" 
                               value="${param.sitioWeb}" placeholder="https://www.misitio.com">
                    </div>
                </div>
                
                <!-- Botones -->
                <div class="form-actions">
                    <button type="submit" class="btn">Crear Usuario</button>
                    <a href="${pageContext.request.contextPath}/principal.jsp" class="btn btn-secondary">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // Mostrar/ocultar campos de Proponente
        document.addEventListener('DOMContentLoaded', function() {
            const tipoUsuarioRadios = document.querySelectorAll('input[name="tipoUsuario"]');
            const proponenteFields = document.getElementById('proponenteFields');
            
            function toggleProponenteFields() {
                const selectedType = document.querySelector('input[name="tipoUsuario"]:checked');
                if (selectedType && selectedType.value === 'PROPONENTE') {
                    proponenteFields.style.display = 'block';
                    document.getElementById('direccion').required = true;
                } else {
                    proponenteFields.style.display = 'none';
                    document.getElementById('direccion').required = false;
                }
            }
            
            tipoUsuarioRadios.forEach(radio => {
                radio.addEventListener('change', toggleProponenteFields);
            });
            
            // Verificar estado inicial
            toggleProponenteFields();
            
            // Validación de contraseñas
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            
            function validatePasswords() {
                if (password.value !== confirmPassword.value) {
                    confirmPassword.setCustomValidity('Las contraseñas no coinciden');
                } else {
                    confirmPassword.setCustomValidity('');
                }
            }
            
            password.addEventListener('input', validatePasswords);
            confirmPassword.addEventListener('input', validatePasswords);
            
            // Mostrar nombre del archivo seleccionado
            const fileInput = document.getElementById('imagen');
            const fileLabel = document.querySelector('.file-input-label');
            
            fileInput.addEventListener('change', function() {
                if (this.files && this.files[0]) {
                    fileLabel.textContent = '📷 ' + this.files[0].name;
                } else {
                    fileLabel.textContent = '📷 Seleccionar imagen';
                }
            });
        });
    </script>
</body>
</html>
