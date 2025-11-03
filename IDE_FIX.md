# Solución para errores de compilación en el IDE

El código compila correctamente con Maven (`mvn compile`), pero el IDE (IntelliJ) muestra errores porque está usando caché o compilando desde una ubicación diferente.

## Solución rápida:

1. **Invalidar caché del IDE:**
   - En IntelliJ: `File` → `Invalidate Caches...` → `Invalidate and Restart`
   - Esto forzará al IDE a recompilar todo desde cero

2. **Reimportar proyecto Maven:**
   - Click derecho en `pom.xml` → `Maven` → `Reload Project`
   - O: `View` → `Tool Windows` → `Maven` → Click en el ícono de refresh

3. **Forzar recompilación:**
   - `Build` → `Rebuild Project`
   - Esto recompilará todas las clases usando la configuración de Maven

4. **Verificar que el módulo esté configurado correctamente:**
   - `File` → `Project Structure` → `Modules`
   - Asegúrate de que `Lab2PDA` tenga:
     - `src/main/java` como fuente
     - `target/generated-sources/wsimport` como fuente (solo si contiene clases)
     - `target/classes` como output

5. **Si el problema persiste:**
   - Cierra IntelliJ
   - Elimina `.idea` y `*.iml` (si es seguro hacerlo)
   - Vuelve a abrir el proyecto como proyecto Maven

## Verificación:

Después de los pasos anteriores, ejecuta:
```bash
mvn clean compile
```

Si Maven compila sin errores, el código está correcto. Los errores del IDE son solo de caché.

