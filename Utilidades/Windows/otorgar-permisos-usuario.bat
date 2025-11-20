@echo off
REM Script para otorgar permisos al usuario culturarte en la base de datos
REM Uso: otorgar-permisos-usuario.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Configurando Usuario y Permisos MySQL
echo ==========================================
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
    echo Buscado en:
    echo   - C:\xampp\mysql\bin\
    echo   - C:\Program Files\MySQL\MySQL Server 8.0\bin\
    echo   - C:\Program Files\MySQL\MySQL Server 8.4\bin\
    echo.
    echo Por favor, especifica la ruta manualmente
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

REM Crear la base de datos si no existe
echo Creando base de datos si no existe...
"%MYSQL_PATH%" -u root -e "CREATE DATABASE IF NOT EXISTS culturarte;" 2>nul
if errorlevel 1 (
    echo Advertencia: No se pudo crear la base de datos
    echo Puede que necesites ingresar la contraseña de root
    echo.
    echo Intentando con contraseña...
    echo Por favor, ingresa la contraseña de root cuando se solicite:
    "%MYSQL_PATH%" -u root -p -e "CREATE DATABASE IF NOT EXISTS culturarte;"
) else (
    echo Base de datos creada o ya existe
)

REM Crear el usuario culturarte si no existe
echo.
echo Creando usuario culturarte si no existe...
"%MYSQL_PATH%" -u root -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>nul
if errorlevel 1 (
    echo Advertencia: No se pudo crear el usuario automaticamente
    echo Puede que el usuario ya exista o necesites ingresar la contraseña de root
    echo.
    echo Intentando con contraseña...
    echo Por favor, ingresa la contraseña de root cuando se solicite:
    "%MYSQL_PATH%" -u root -p -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';"
) else (
    echo Usuario creado o ya existe
)

REM Otorgar permisos
echo.
echo Otorgando permisos al usuario culturarte...
"%MYSQL_PATH%" -u root -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>nul
if errorlevel 1 (
    echo ERROR: No se pudo otorgar permisos automaticamente
    echo.
    echo Intentando con contraseña...
    echo Por favor, ingresa la contraseña de root cuando se solicite:
    "%MYSQL_PATH%" -u root -p -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';"
) else (
    echo Permisos otorgados correctamente
)

REM Aplicar cambios
echo.
echo Aplicando cambios...
"%MYSQL_PATH%" -u root -e "FLUSH PRIVILEGES;" 2>nul
if errorlevel 1 (
    echo Por favor, ingresa la contraseña de root cuando se solicite:
    "%MYSQL_PATH%" -u root -p -e "FLUSH PRIVILEGES;"
) else (
    echo Cambios aplicados
)

echo.
echo ==========================================
echo   Configuracion completada
echo ==========================================
echo.
echo El usuario "culturarte" ahora tiene acceso a la base de datos "culturarte"
echo.
echo Credenciales:
echo   Usuario: culturarte
echo   Contrasena: culturarte123
echo   Base de datos: culturarte
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul


