<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!doctype html>
<html>
<head>
    <title>Alta de Propuesta</title>
    <meta charset="utf-8"/>
    <style>
        body{background:#0d0d0d;color:#eee;font-family:system-ui,Segoe UI,Roboto}
        form{max-width:760px;margin:16px auto;padding:16px;border:1px solid #444;border-radius:12px;background:#171717}
        fieldset{border:none;margin:0;padding:0 0 8px}
        label{display:block;margin:10px 0 4px}
        input,select,textarea{width:100%;padding:8px;border:1px solid #555;border-radius:8px;background:#111;color:#eee}
        .row{display:grid;grid-template-columns:1fr 1fr;gap:12px}
        .err{background:#3b0e0e;border:1px solid #884444;color:#ffb7b7;padding:8px;border-radius:8px;margin-bottom:8px}
        .actions{display:flex;gap:10px;justify-content:flex-end;margin-top:12px}
        .hint{color:#aaa;font-size:.9em}
        .checks{display:flex;gap:12px;flex-wrap:wrap;margin-top:6px}
        button{padding:8px 14px;border:1px solid #666;background:#222;border-radius:8px;color:#eee;cursor:pointer}
    </style>
    <script>
        function validar() {
            const f = document.forms[0];
            const titulo = f.titulo.value.trim();
            const descripcion = f.descripcion.value.trim();
            const lugar = f.lugar.value.trim();
            const fecha = f.fecha.value;
            const precio = parseFloat(f.precioEntrada.value);
            const monto  = parseFloat(f.montoNecesario.value);
            const categoria = f.categoria.value;
            const retornos = [...f.querySelectorAll('input[name="retornos"]:checked')];

            let errores = [];
            if (!categoria) errores.push("Seleccioná una categoría.");
            if (!titulo) errores.push("El título es obligatorio.");
            if (!descripcion) errores.push("La descripción es obligatoria.");
            if (!lugar) errores.push("El lugar es obligatorio.");

            if (!fecha) errores.push("Seleccioná una fecha.");
            else {
                const hoy = new Date(); hoy.setHours(0,0,0,0);
                const fsel = new Date(fecha+"T00:00:00");
                if (fsel < hoy) errores.push("La fecha debe ser hoy o posterior.");
            }

            if (!(precio > 0)) errores.push("El precio de entrada debe ser mayor a 0.");
            if (!(monto  > 0)) errores.push("El monto necesario debe ser mayor a 0.");
            if (retornos.length === 0) errores.push("Seleccioná al menos un tipo de retorno.");

            const box = document.getElementById('errores');
            box.innerHTML = "";
            if (errores.length) {
                box.innerHTML = "<div class='err'><b>Corregí:</b><ul><li>" + errores.join("</li><li>") + "</li></ul></div>";
                return false;
            }
            return true;
        }
        document.addEventListener('DOMContentLoaded', () => {
            // set min date = hoy
            const input = document.querySelector('input[type="date"]');
            if (input) {
                const d = new Date();
                const pad = n => String(n).padStart(2,'0');
                input.min = d.getFullYear()+"-"+pad(d.getMonth()+1)+"-"+pad(d.getDate());
            }
        });
    </script>
</head>
<body>

<form method="post" action="<%=request.getContextPath()%>/altaPropuesta" enctype="multipart/form-data" onsubmit="return validar()">
    <h1>Alta de Propuesta</h1>

    <div id="errores">
        <% if (request.getAttribute("errores") != null) { %>
        <div class="err">
            <b>Corregí:</b>
            <ul>
                <% for (String e : (java.util.List<String>) request.getAttribute("errores")) { %>
                <li><%= e %></li>
                <% } %>
            </ul>
        </div>
        <% } %>
    </div>

    <fieldset class="row">
        <div>
            <label>Categoría</label>
            <select name="categoria" required>
                <option value="">-- Elegir --</option>
                <option>Teatro</option>
                <option>Música</option>
                <option>Danza</option>
                <option>Exposición</option>
                <!-- completá con tus categorías del servidor central -->
            </select>
        </div>
        <div>
            <label>Título</label>
            <input name="titulo" maxlength="120" required/>
        </div>
    </fieldset>

    <fieldset>
        <label>Descripción</label>
        <textarea name="descripcion" rows="4" required></textarea>
    </fieldset>

    <fieldset class="row">
        <div>
            <label>Lugar</label>
            <input name="lugar" required/>
        </div>
        <div>
            <label>Fecha (AAAA-MM-DD)</label>
            <input type="date" name="fecha" required/>
        </div>
    </fieldset>

    <fieldset class="row">
        <div>
            <label>Precio de entrada</label>
            <input type="number" name="precioEntrada" min="1" step="0.01" required/>
        </div>
        <div>
            <label>Monto necesario</label>
            <input type="number" name="montoNecesario" min="1" step="0.01" required/>
        </div>
    </fieldset>

    <fieldset>
        <label>Tipos de retorno</label>
        <div class="checks">
            <label><input type="checkbox" name="retornos" value="Entradas"> Entradas</label>
            <label><input type="checkbox" name="retornos" value="Porcentaje"> Porcentaje</label>
            <label><input type="checkbox" name="retornos" value="Acceso Backstage"> Acceso Backstage</label>
            <!-- ajustá a tus tipos reales -->
        </div>
    </fieldset>

    <fieldset>
        <label>Imagen (opcional)</label>
        <input type="file" name="imagen" accept="image/*"/>
        <div class="hint">Se mostrará recortada a 100×100 px en la UI. :contentReference[oaicite:3]{index=3}</div>
    </fieldset>

    <div class="actions">
        <a href="<%=request.getContextPath()%>/" class="btn">Cancelar</a>
        <button type="submit">Crear propuesta</button>
    </div>
</form>

</body>
</html>