<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cuenta Eliminada - Culturarte</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <jsp:include page="estiloCabezalComun.jsp"/>
</head>
<body class="bg-light">
    <div class="container">
        <jsp:include page="cabezalComun.jsp"/>

        <div class="py-5">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card shadow-sm text-center">
                        <div class="card-body py-5">
                            <div class="mb-4">
                                <i class="bi bi-check-circle text-success" style="font-size: 4rem;"></i>
                            </div>
                            <h3 class="mb-3">Cuenta Eliminada</h3>
                            <p class="text-muted mb-4">
                                Tu cuenta de proponente ha sido eliminada exitosamente.
                            </p>
                            <a href="<%= request.getContextPath() %>/principal" class="btn btn-primary">
                                Volver al Inicio
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>