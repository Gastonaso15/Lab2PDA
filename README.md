# Sistema Culturarte - Lab2PDA

Este repositorio contiene el servidor web del sistema Culturarte, que debe ejecutarse junto con el servidor central (Lab1PDA).

## 📁 Estructura del Proyecto

Para que todo funcione correctamente, los repositorios deben estar clonados en la misma carpeta padre. Puedes usar cualquier nombre para esa carpeta:

```
[cualquier_carpeta]/
├── Lab1PDA/              # Servidor Central (repositorio separado)
│   ├── src/
│   ├── pom.xml
│   └── ...
└── Lab2PDA/               # Servidor Web (este repositorio)
    ├── src/
    ├── pom.xml
    ├── apache-tomcat-10.1.48/    # Tomcat instalado
    ├── Utilidades/
    │   ├── Linux/
    │   │   ├── compilar.sh
    │   │   ├── iniciar-todo.sh
    │   │   ├── iniciar-servicios.sh
    │   │   ├── detener-servicios.sh
    │   │   └── detener-puerto-9128.sh
    │   └── Windows/
    │       ├── compilar.bat
    │       ├── iniciar-todo.bat
    │       ├── iniciar-servicios.bat
    │       ├── detener-servicios.bat
    │       └── detener-puerto-9128.bat
    └── README.md
```

**Ejemplo:** Puedes clonar ambos repositorios en el escritorio:
```
Escritorio/
├── Lab1PDA/    (clonado desde GitHub)
└── Lab2PDA/    (clonado desde GitHub)
```

## 🚀 Inicio Rápido

### 1. Compilar el Proyecto

**En Linux/Mac:**
```bash
cd [cualquier_carpeta]/Lab2PDA/Utilidades/Linux
./compilar.sh
```

**En Windows:**
```bash
cd [cualquier_carpeta]\Lab2PDA\Utilidades\Windows
compilar.bat
```

Este script compila ambos proyectos y genera:
- `Lab1PDA/dist/servidor.jar` - Servidor Central
- `Lab2PDA/dist/web.war` - Aplicación web

### 2. Iniciar el Sistema

**Opción A: Iniciar TODO (Servidor Central + Estación de Trabajo + Tomcat)**

**En Linux/Mac:**
```bash
cd [cualquier_carpeta]/Lab2PDA/Utilidades/Linux
./iniciar-todo.sh
```

**En Windows:**
```bash
cd [cualquier_carpeta]\Lab2PDA\Utilidades\Windows
iniciar-todo.bat
```

**Opción B: Iniciar solo Servicios (Servidor Central + Tomcat, SIN Estación de Trabajo)**

**En Linux/Mac:**
```bash
cd [cualquier_carpeta]/Lab2PDA/Utilidades/Linux
./iniciar-servicios.sh
```

**En Windows:**
```bash
cd [cualquier_carpeta]\Lab2PDA\Utilidades\Windows
iniciar-servicios.bat
```

### 3. Acceder a la Aplicación

Una vez iniciado el sistema, puedes acceder a:

- **Web Services:** http://localhost:9128/culturarteWS
- **Aplicación Web:** http://localhost:8080/web
- **HTML App Manager:** http://localhost:8080/manager/html
  - Usuario: `admin`
  - Contraseña: `admin`

### 4. Detener el Sistema

**En Linux/Mac:**
```bash
cd [cualquier_carpeta]/Lab2PDA/Utilidades/Linux
./detener-servicios.sh
```

**En Windows:**
```bash
cd [cualquier_carpeta]\Lab2PDA\Utilidades\Windows
detener-servicios.bat
```

## 📋 Scripts Disponibles

### Scripts de Compilación

#### `compilar.sh` (Linux/Mac) / `compilar.bat` (Windows)

Compila ambos proyectos (Lab1PDA y Lab2PDA) y genera los archivos necesarios:

- **Genera:**
  - `Lab1PDA/dist/servidor.jar` - Servidor Central con todas las dependencias
  - `Lab2PDA/dist/web.war` - Aplicación web lista para desplegar

- **Configura:**
  - Archivos de configuración en `~/.Culturarte/` (Linux/Mac) o `%USERPROFILE%\.Culturarte\` (Windows)

### Scripts de Ejecución

#### `iniciar-todo.sh` / `iniciar-todo.bat`

Inicia el sistema completo:
- ✅ Servidor Central (Web Services en puerto 9128)
- ✅ Estación de Trabajo (GUI)
- ✅ Tomcat (Servidor Web en puerto 8080)

**Uso:**
```bash
# Linux/Mac
./iniciar-todo.sh

# Windows
iniciar-todo.bat
```

#### `iniciar-servicios.sh` / `iniciar-servicios.bat`

Inicia solo los servicios (sin la Estación de Trabajo):
- ✅ Servidor Central (Web Services en puerto 9128)
- ✅ Tomcat (Servidor Web en puerto 8080)

**Uso:**
```bash
# Linux/Mac
./iniciar-servicios.sh

# Windows
iniciar-servicios.bat
```

**Nota:** Útil cuando solo necesitas probar la aplicación web sin la interfaz gráfica.

### Scripts de Detención

#### `detener-servicios.sh` / `detener-servicios.bat`

Detiene todos los servicios iniciados por los scripts anteriores:
- Detiene el Servidor Central (Web Services)
- Detiene la Estación de Trabajo (si está corriendo)
- Detiene Tomcat

**Uso:**
```bash
# Linux/Mac
./detener-servicios.sh

# Windows
detener-servicios.bat
```

#### `detener-puerto-9128.sh` / `detener-puerto-9128.bat`

Detiene cualquier proceso que esté usando el puerto 9128 (puerto del Servidor Central).

**Cuándo usarlo:**
- Cuando el puerto 9128 está ocupado y no puedes iniciar el servidor
- Cuando `detener-servicios.sh` no logra detener el proceso
- Cuando necesitas liberar el puerto manualmente

**Uso:**
```bash
# Linux/Mac
./detener-puerto-9128.sh

# Windows
detener-puerto-9128.bat
```

## 🔧 Requisitos

### Software Necesario

1. **Java JDK 11 o superior**
   - Verificar: `java -version`

2. **Apache Maven 3.6 o superior**
   - Verificar: `mvn -version`

3. **Apache Tomcat 10.1.x**
   - Debe estar instalado en `Lab2PDA/apache-tomcat-10.1.48/`
   - O configurar la variable de entorno `CATALINA_HOME`

4. **MySQL/MariaDB** (para la base de datos)
   - Base de datos: `culturarte`
   - Usuario: `culturarte`
   - Contraseña: `culturarte123`

### Estructura de Carpetas Requerida

Los scripts esperan que los repositorios estén clonados en la misma carpeta padre. **Puedes usar cualquier nombre para esa carpeta**:

```
[cualquier_carpeta]/
├── Lab1PDA/          # Clonar desde GitHub
└── Lab2PDA/          # Clonar desde GitHub
```

**Ejemplos:**
- `Escritorio/Lab1PDA` y `Escritorio/Lab2PDA`
- `C:\Proyectos\PDA\Lab1PDA` y `C:\Proyectos\PDA\Lab2PDA`
- `~/proyectos/Lab1PDA` y `~/proyectos/Lab2PDA`

## 🐛 Solución de Problemas

### Error: "No se encuentra el directorio Lab1PDA"

**Problema:** Los scripts no pueden encontrar Lab1PDA o Lab2PDA.

**Solución:**
1. Verifica que ambos repositorios estén clonados en la misma carpeta padre (puede tener cualquier nombre):
   ```
   [cualquier_carpeta]/
   ├── Lab1PDA/
   └── Lab2PDA/
   ```

2. Ejecuta los scripts desde la carpeta correcta:
   ```bash
   cd [cualquier_carpeta]/Lab2PDA/Utilidades/Linux
   ./compilar.sh
   ```
   
   O en Windows:
   ```bash
   cd [cualquier_carpeta]\Lab2PDA\Utilidades\Windows
   compilar.bat
   ```

### Error: "El puerto 9128 ya está en uso"

**Problema:** El puerto del Servidor Central está ocupado.

**Solución:**
1. Usa el script de detención:
   ```bash
   # Linux/Mac
   ./detener-puerto-9128.sh
   
   # Windows
   detener-puerto-9128.bat
   ```

2. O detén todos los servicios:
   ```bash
   # Linux/Mac
   ./detener-servicios.sh
   
   # Windows
   detener-servicios.bat
   ```

### Error: "No se encontró Tomcat instalado"

**Problema:** Los scripts no pueden encontrar Apache Tomcat.

**Solución:**
1. Instala Tomcat en `Lab2PDA/apache-tomcat-10.1.48/`
2. O configura la variable de entorno `CATALINA_HOME`:
   ```bash
   # Linux/Mac
   export CATALINA_HOME=/ruta/a/tomcat
   
   # Windows
   set CATALINA_HOME=C:\ruta\a\tomcat
   ```

### Error: "No se encontraron los archivos compilados"

**Problema:** Los scripts de ejecución no encuentran `servidor.jar` o `web.war`.

**Solución:**
1. Compila primero el proyecto:
   ```bash
   cd Lab2PDA/Utilidades/Linux
   ./compilar.sh
   ```

2. Verifica que los archivos se generaron:
   - `Lab1PDA/dist/servidor.jar` ✅
   - `Lab2PDA/dist/web.war` ✅

### Tomcat no inicia

**Problema:** Tomcat no responde después de ejecutar los scripts.

**Solución:**
1. Espera 30-60 segundos (Tomcat puede tardar en iniciar)
2. Revisa la ventana de CMD de Tomcat para ver errores
3. Verifica que el puerto 8080 no esté ocupado:
   ```bash
   # Linux/Mac
   lsof -i :8080
   
   # Windows
   netstat -ano | findstr :8080
   ```

## 📝 Notas Importantes

1. **Estructura de Carpetas:** Los scripts están diseñados para funcionar cuando `Lab1PDA` y `Lab2PDA` están en la misma carpeta padre. Puedes usar cualquier nombre para esa carpeta (no tiene que ser "PDA").

2. **Tomcat:** El script busca Tomcat primero en `Lab2PDA/apache-tomcat-10.1.48/`, luego en otras ubicaciones comunes.

3. **Archivos Compilados:** Los archivos compilados se generan en:
   - `Lab1PDA/dist/servidor.jar` ✅
   - `Lab2PDA/dist/web.war` ✅

4. **Configuración:** Los archivos de configuración se guardan en:
   - **Linux/Mac:** `~/.Culturarte/` (ej: `/home/usuario/.Culturarte/`)
   - **Windows:** `%USERPROFILE%\.Culturarte\` (ej: `C:\Users\TuUsuario\.Culturarte\`)

5. **Puertos:**
   - **9128:** Servidor Central (Web Services)
   - **8080:** Tomcat (Servidor Web)

6. **Logs:** Los logs se guardan en:
   - Linux/Mac: `/tmp/culturarte-*.log`
   - Windows: `Lab2PDA/Utilidades/Windows/culturarte-*.log`

## 🔗 Enlaces Útiles

- **Web Services WSDL:** http://localhost:9128/culturarteWS/usuarios?wsdl
- **Aplicación Web:** http://localhost:8080/web
- **HTML App Manager:** http://localhost:8080/manager/html

---

**Última actualización:** Noviembre 2025
