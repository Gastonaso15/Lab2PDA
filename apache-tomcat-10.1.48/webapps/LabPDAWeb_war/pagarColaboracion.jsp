<%@ page import="culturarte.servicios.cliente.propuestas.DtColaboracion, com.culturarteWeb.util.WSFechaPropuesta, java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pagar Colaboración - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
    <style>
        body {
            background-color: #f8f9fa;
            padding-top: 2rem;
            padding-bottom: 2rem;
        }
        .payment-form {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .payment-method-section {
            display: none;
        }
        .payment-method-section.active {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>
    </div>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <h1 class="mb-4"><i class="bi bi-credit-card"></i> Realizar Pago</h1>

                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= error %>
                    </div>
                <% } %>

                <% 
                    DtColaboracion colaboracion = (DtColaboracion) request.getAttribute("colaboracion");
                    if (colaboracion == null) {
                %>
                    <div class="alert alert-warning" role="alert">
                        No se encontró la colaboración especificada.
                    </div>
                    <a href="<%= request.getContextPath() %>/listarColaboracionesParaPagar" class="btn btn-secondary">Volver</a>
                <% } else { 
                    String tituloPropuesta = colaboracion.getPropuesta() != null ? colaboracion.getPropuesta().getTitulo() : "Sin título";
                    Double monto = colaboracion.getMonto() != null ? colaboracion.getMonto() : 0.0;
                %>
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Detalles de la Colaboración</h5>
                        </div>
                        <div class="card-body">
                            <p><strong>Propuesta:</strong> <%= tituloPropuesta %></p>
                            <p><strong>Monto a pagar:</strong> $<%= String.format("%.2f", monto) %></p>
                        </div>
                    </div>

                    <div class="payment-form">
                        <form action="pagarColaboracion" method="post" id="formPago" novalidate>
                            <input type="hidden" name="idColaboracion" value="<%= colaboracion.getId() %>">
                            <input type="hidden" name="monto" value="<%= monto %>">

                            <div class="mb-4">
                                <label class="form-label"><strong>Forma de Pago:</strong></label>
                                <select name="formaPago" id="formaPago" class="form-select" required onchange="mostrarCamposPago()">
                                    <option value="">-- Seleccione una forma de pago --</option>
                                    <option value="TARJETA">Tarjeta</option>
                                    <option value="TRANSFERENCIA_BANCARIA">Transferencia Bancaria</option>
                                    <option value="PAYPAL">PayPal</option>
                                </select>
                            </div>

                            <div id="camposTarjeta" class="payment-method-section">
                                <h5 class="mb-3">Datos de la Tarjeta</h5>

                                <div class="mb-3">
                                    <label for="tipoTarjeta" class="form-label">Tipo de Tarjeta:</label>
                                    <select name="tipoTarjeta" id="tipoTarjeta" class="form-select">
                                        <option value="OCA">OCA</option>
                                        <option value="VISA">VISA</option>
                                        <option value="MASTERCARD">Mastercard</option>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label for="numeroTarjeta" class="form-label">Número de Tarjeta:</label>
                                    <input type="text" name="numeroTarjeta" id="numeroTarjeta" class="form-control"
                                           placeholder="Ej: 1234 5678 9012 3456" maxlength="19"
                                           pattern="^(\d{4}[\s-]?){3}\d{4}$" inputmode="numeric" required>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="fechaVencimiento" class="form-label">Fecha de Vencimiento:</label>
                                        <input type="text" name="fechaVencimiento" id="fechaVencimiento" class="form-control"
                                               placeholder="MM/AA" maxlength="5"
                                               pattern="^(0[1-9]|1[0-2])\/\d{2}$" inputmode="numeric" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="cvc" class="form-label">CVC:</label>
                                        <input type="text" name="cvc" id="cvc" class="form-control"
                                               placeholder="Ej: 123" maxlength="3"
                                               pattern="^\d{3}$" inputmode="numeric" required>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="nombreTitularTarjeta" class="form-label">Nombre del Titular:</label>
                                    <input type="text" name="nombreTitularTarjeta" id="nombreTitularTarjeta" class="form-control"
                                           placeholder="Ej: Juan Pérez" pattern="^[a-zA-ZÀ-ÿ\s]+$" required>
                                </div>
                            </div>

                            <div id="camposTransferencia" class="payment-method-section">
                                <h5 class="mb-3">Datos de Transferencia Bancaria</h5>
                                <div class="mb-3">
                                    <label for="nombreBanco" class="form-label">Nombre del Banco:</label>
                                    <input type="text" name="nombreBanco" id="nombreBanco" class="form-control"
                                           placeholder="Ej: Banco República" required>
                                </div>
                                <div class="mb-3">
                                    <label for="numeroCuenta" class="form-label">Número de Cuenta:</label>
                                    <input type="text" name="numeroCuenta" id="numeroCuenta" class="form-control"
                                           placeholder="Ej: 1234567890"
                                           pattern="^[0-9]{6,20}$" inputmode="numeric" required>
                                </div>
                                <div class="mb-3">
                                    <label for="nombreTitularTransferencia" class="form-label">Nombre del Titular:</label>
                                    <input type="text" name="nombreTitularTransferencia" id="nombreTitularTransferencia"
                                           class="form-control" placeholder="Ej: Ana López"
                                           pattern="^[a-zA-ZÀ-ÿ\s]+$" required>
                                </div>
                            </div>

                            <div id="camposPayPal" class="payment-method-section">
                                <h5 class="mb-3">Datos de PayPal</h5>
                                <div class="mb-3">
                                    <label for="numeroCuentaPayPal" class="form-label">Correo o Cuenta PayPal:</label>
                                    <input type="email" name="numeroCuentaPayPal" id="numeroCuentaPayPal" class="form-control"
                                           placeholder="Ej: usuario@paypal.com" required>
                                </div>
                                <div class="mb-3">
                                    <label for="nombreTitularPayPal" class="form-label">Nombre del Titular:</label>
                                    <input type="text" name="nombreTitularPayPal" id="nombreTitularPayPal"
                                           class="form-control" placeholder="Ej: Carlos Rodríguez"
                                           pattern="^[a-zA-ZÀ-ÿ\s]+$" required>
                                </div>
                            </div>

                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                <a href="<%= request.getContextPath() %>/listarColaboracionesParaPagar" class="btn btn-outline-secondary">
                                    Cancelar
                                </a>
                                <button type="submit" class="btn btn-success">
                                    <i class="bi bi-check-circle"></i> Confirmar Pago
                                </button>
                            </div>
                        </form>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        function mostrarCamposPago() {
            const formaPago = document.getElementById('formaPago').value;
            const secciones = ['camposTarjeta', 'camposTransferencia', 'camposPayPal'];

            secciones.forEach(id => {
                const section = document.getElementById(id);
                section.classList.remove('active');
                section.querySelectorAll('input, select').forEach(input => input.required = false);
            });

            if (formaPago) {
                const activeSection = document.getElementById(
                    formaPago === 'TARJETA' ? 'camposTarjeta' :
                    formaPago === 'TRANSFERENCIA_BANCARIA' ? 'camposTransferencia' : 'camposPayPal'
                );
                activeSection.classList.add('active');
                activeSection.querySelectorAll('input, select').forEach(input => input.required = true);
            }
        }

        document.getElementById('numeroTarjeta').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '').substring(0, 16);
            e.target.value = value.replace(/(.{4})/g, '$1 ').trim();
        });

        document.getElementById('fechaVencimiento').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '').substring(0, 4);
            if (value.length >= 3) {
                e.target.value = value.substring(0, 2) + '/' + value.substring(2);
            } else {
                e.target.value = value;
            }
        });

        document.getElementById('formPago').addEventListener('submit', function(e) {
            if (!e.target.checkValidity()) {
                e.preventDefault();
                e.stopPropagation();
                alert('Por favor, complete los campos correctamente.');
            }
        });
    </script>
</body>
</html>
