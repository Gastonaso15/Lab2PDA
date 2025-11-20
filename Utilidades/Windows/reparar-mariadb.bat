@echo off
REM Script para reparar las tablas del sistema de MariaDB/MySQL
REM Uso: reparar-mariadb.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Reparando Tablas del Sistema MariaDB
echo ==========================================
echo.
echo ADVERTENCIA: Este script requiere acceso de root
echo.

REM Buscar mysql.exe
set "MYSQL_PATH="
if exist "C:\xampp\mysql\bin\mysql.exe" (
    set "MYSQL_PATH=C:\xampp\mysql\bin\mysql.exe"
) else if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
    set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
) else if exist "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" (
    set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
) else (
    echo ERROR: No se encontro mysql.exe
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo MySQL encontrado en: %MYSQL_PATH%
echo.

REM Verificar que MySQL esté corriendo
echo Verificando que MySQL este corriendo...
netstat -ano | findstr :3306 | findstr LISTENING >nul
if %errorlevel% == 0 (
    echo MySQL esta corriendo en el puerto 3306
) else (
    echo ERROR: MySQL no esta corriendo en el puerto 3306
    echo Por favor, inicia MySQL desde XAMPP
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)
echo.

echo ==========================================
echo   PASO 1: Reparar tablas del sistema
echo ==========================================
echo.
echo Esto reparara las tablas mysql.user, mysql.db, etc.
echo.
echo Por favor, ingresa la contraseña de root cuando se solicite
echo (Si no tienes contraseña, presiona Enter)
echo.
pause

REM Reparar tablas del sistema
echo.
echo Reparando tablas del sistema...
"%MYSQL_PATH%" -u root -p -e "REPAIR TABLE mysql.user, mysql.db, mysql.tables_priv, mysql.columns_priv, mysql.procs_priv;" 2>nul

if errorlevel 1 (
    echo.
    echo Intentando sin contraseña...
    "%MYSQL_PATH%" -u root -e "REPAIR TABLE mysql.user, mysql.db, mysql.tables_priv, mysql.columns_priv, mysql.procs_priv;" 2>nul
)

echo.
echo ==========================================
echo   PASO 2: Verificar y otorgar permisos
echo ==========================================
echo.

REM Verificar que la base de datos existe
echo Verificando que la base de datos culturarte existe...
"%MYSQL_PATH%" -u root -e "SHOW DATABASES LIKE 'culturarte';" 2>nul | findstr culturarte >nul
if errorlevel 1 (
    echo ERROR: La base de datos culturarte no existe
    echo Por favor, creala primero o restaura desde el respaldo
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
) else (
    echo Base de datos culturarte encontrada
)

REM Verificar que el usuario existe
echo.
echo Verificando que el usuario culturarte existe...
"%MYSQL_PATH%" -u root -e "SELECT User, Host FROM mysql.user WHERE User='culturarte';" 2>nul | findstr culturarte >nul
if errorlevel 1 (
    echo Usuario no encontrado, creandolo...
    "%MYSQL_PATH%" -u root -e "CREATE USER 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>nul
    if errorlevel 1 (
        echo Por favor, ingresa la contraseña de root:
        "%MYSQL_PATH%" -u root -p -e "CREATE USER 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';"
    )
) else (
    echo Usuario culturarte encontrado
)

REM Otorgar permisos
echo.
echo Otorgando permisos...
"%MYSQL_PATH%" -u root -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>nul
if errorlevel 1 (
    echo Por favor, ingresa la contraseña de root:
    "%MYSQL_PATH%" -u root -p -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';"
)

REM Intentar FLUSH PRIVILEGES
echo.
echo Aplicando cambios...
"%MYSQL_PATH%" -u root -e "FLUSH PRIVILEGES;" 2>nul
if errorlevel 1 (
    echo Advertencia: FLUSH PRIVILEGES fallo, pero los permisos pueden estar aplicados
    echo.
    echo Si el problema persiste, reinicia MySQL desde XAMPP
)

echo.
echo ==========================================
echo   Verificacion
echo ==========================================
echo.
echo Verificando permisos del usuario culturarte...
echo.
echo Ejecutando: SHOW GRANTS FOR 'culturarte'@'localhost';
echo.
"%MYSQL_PATH%" -u root -e "SHOW GRANTS FOR 'culturarte'@'localhost';" 2>nul
if errorlevel 1 (
    echo Por favor, ingresa la contraseña de root:
    "%MYSQL_PATH%" -u root -p -e "SHOW GRANTS FOR 'culturarte'@'localhost';"
)

echo.
echo ==========================================
echo   Instrucciones Adicionales
echo ==========================================
echo.
echo Si el problema persiste:
echo.
echo 1. Reinicia MySQL desde el panel de control de XAMPP
echo    - Deten MySQL
echo    - Espera 5 segundos
echo    - Inicia MySQL nuevamente
echo.
echo 2. Si aun no funciona, repara las tablas manualmente:
echo    - Abre phpMyAdmin
echo    - Selecciona la base de datos "mysql"
echo    - Ve a la tabla "user"
echo    - Haz clic en "Operaciones" ^> "Reparar tabla"
echo.
echo 3. Como ultimo recurso, reinicia el servidor
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul


