# Solución de Problemas con MySQL

## 🔍 Diagnóstico del Problema

Si ves el error: **"Could not initialize class culturarte.persistencia.JPAUtil"**, significa que hay un problema de conexión a la base de datos MySQL.

## 📋 Verificar tu Configuración

### 1. ¿Qué estás usando: XAMPP o Docker?

**XAMPP:**
- MySQL corre en el puerto **3306** (puerto por defecto)
- Se inicia desde el panel de control de XAMPP

**Docker:**
- MySQL corre en el puerto **3307** (mapeado desde el puerto interno 3306)
- Se inicia con `docker-compose up`

### 2. Verificar qué puerto está usando MySQL

**En Windows (CMD o PowerShell):**
```bash
netstat -ano | findstr :3306
netstat -ano | findstr :3307
```

**En Linux/Mac:**
```bash
lsof -i :3306
lsof -i :3307
```

Si ves procesos en el puerto 3306, probablemente estás usando XAMPP.
Si ves procesos en el puerto 3307, probablemente estás usando Docker.

## 🔧 Solución según tu caso

### Opción A: Usando XAMPP (Puerto 3306)

1. **Verifica que MySQL esté corriendo en XAMPP:**
   - Abre el panel de control de XAMPP
   - Verifica que MySQL esté en estado "Running"
   - El puerto debe ser **3306**

2. **Verifica la configuración en `~/.Culturarte/database.properties`:**
   
   **En Windows:** `C:\Users\TuUsuario\.Culturarte\database.properties`
   
   **En Linux/Mac:** `~/.Culturarte/database.properties`

   Debe tener:
   ```properties
   db.url=jdbc:mysql://localhost:3306/culturarte
   db.user=culturarte
   db.password=culturarte123
   ```

3. **Crea la base de datos si no existe:**
   
   Abre phpMyAdmin (http://localhost/phpmyadmin) o usa la línea de comandos:
   
   ```sql
   CREATE DATABASE IF NOT EXISTS culturarte;
   CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';
   GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';
   FLUSH PRIVILEGES;
   ```

### Opción B: Usando Docker (Puerto 3307)

1. **Verifica que Docker esté corriendo:**
   ```bash
   docker ps
   ```
   
   Deberías ver un contenedor llamado `culturarte_db` corriendo.

2. **Si no está corriendo, inícialo:**
   ```bash
   cd Lab1PDA
   docker-compose up -d
   ```

3. **Modifica `~/.Culturarte/database.properties`:**
   
   Cambia el puerto de 3306 a 3307:
   ```properties
   db.url=jdbc:mysql://localhost:3307/culturarte
   db.user=culturarte
   db.password=culturarte123
   ```

### Opción C: Conflicto de Puertos (XAMPP y Docker al mismo tiempo)

Si tienes ambos corriendo, tendrás un conflicto. **Elige uno:**

**Para usar XAMPP:**
1. Detén Docker: `docker-compose down`
2. Asegúrate de que XAMPP MySQL esté corriendo
3. Usa puerto 3306 en `database.properties`

**Para usar Docker:**
1. Detén MySQL en XAMPP
2. Inicia Docker: `docker-compose up -d`
3. Usa puerto 3307 en `database.properties`

## 📝 Editar database.properties

### En Windows:

1. Abre el explorador de archivos
2. Ve a: `C:\Users\TuUsuario\.Culturarte\`
3. Abre `database.properties` con el Bloc de notas
4. Modifica la línea `db.url` según tu caso:
   - XAMPP: `db.url=jdbc:mysql://localhost:3306/culturarte`
   - Docker: `db.url=jdbc:mysql://localhost:3307/culturarte`
5. Guarda el archivo

### En Linux/Mac:

```bash
nano ~/.Culturarte/database.properties
```

O:

```bash
code ~/.Culturarte/database.properties
```

## ✅ Verificar que Funciona

1. **Reinicia los servicios:**
   - Detén el servidor central (si está corriendo)
   - Detén Tomcat (si está corriendo)
   - Vuelve a iniciarlos

2. **Verifica los logs:**
   - Busca errores de conexión en los logs
   - Si ves "Connected to MySQL", está funcionando

3. **Prueba la aplicación:**
   - Intenta acceder a la aplicación web
   - Si no aparece el error de JPAUtil, está solucionado

## 🆘 Error: "Read page with wrong checksum" (Corrupción de Aria)

**Problema:** Error de corrupción en las tablas del sistema de MariaDB/MySQL. El comando `REPAIR TABLE` puede ejecutarse indefinidamente mostrando muchos errores.

**Solución RÁPIDA (Recomendada):**

1. **Detén el proceso de reparación si está corriendo:**
   - Presiona `Ctrl+C` en la terminal

2. **Usa la solución rápida (sin reparar tablas):**
   ```bash
   # Windows
   cd Lab2PDA\Utilidades\Windows
   solucion-rapida-permisos.bat
   ```

3. **Reinicia MySQL desde XAMPP:**
   - Abre el panel de control de XAMPP
   - Detén MySQL (Stop)
   - Espera 5-10 segundos
   - Inicia MySQL nuevamente (Start)
   
   **Esto aplicará los permisos sin necesidad de FLUSH PRIVILEGES**

4. **Verifica que funciona:**
   ```bash
   mysql -u culturarte -pculturarte123
   ```
   Luego ejecuta:
   ```sql
   SHOW DATABASES;
   ```
   Deberías ver `culturarte` en la lista.

**Solución ALTERNATIVA (Si la rápida no funciona):**

1. **Reparar solo la tabla user (más rápido):**
   ```sql
   REPAIR TABLE mysql.user;
   FLUSH PRIVILEGES;
   ```

2. **O repara desde phpMyAdmin:**
   - Abre phpMyAdmin
   - Selecciona la base de datos `mysql`
   - Ve a la tabla `user`
   - Haz clic en "Operaciones" > "Reparar tabla"
   - Espera a que termine (puede tardar)
   - Luego ejecuta `FLUSH PRIVILEGES;` desde SQL

**⚠️ ADVERTENCIA:** Si hay mucha corrupción, la reparación puede tardar mucho tiempo o no completarse. En ese caso, considera reinstalar MySQL/MariaDB en XAMPP.

## 🆘 Si Nada Funciona

1. **Verifica que MySQL esté realmente corriendo:**
   ```bash
   # Windows
   netstat -ano | findstr :3306
   
   # Linux/Mac
   sudo systemctl status mysql
   # o
   ps aux | grep mysql
   ```

2. **Verifica las credenciales:**
   - Usuario: `culturarte`
   - Contraseña: `culturarte123`
   - Base de datos: `culturarte`

3. **Recrea la base de datos:**
   ```sql
   DROP DATABASE IF EXISTS culturarte;
   CREATE DATABASE culturarte;
   CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';
   GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';
   FLUSH PRIVILEGES;
   ```

4. **Verifica el firewall:**
   - Asegúrate de que el puerto 3306 o 3307 no esté bloqueado

## 📌 Resumen Rápido

| Usas | Puerto | Configuración |
|------|--------|---------------|
| XAMPP | 3306 | `db.url=jdbc:mysql://localhost:3306/culturarte` |
| Docker | 3307 | `db.url=jdbc:mysql://localhost:3307/culturarte` |

**Archivo a editar:** `~/.Culturarte/database.properties` (o `C:\Users\TuUsuario\.Culturarte\database.properties` en Windows)

