@echo off
REM Script para restaurar la base de datos desde el respaldo SQL
REM Uso: restaurar-base-datos.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Restaurando Base de Datos Culturarte
echo ==========================================
echo.

REM Obtener directorio del script
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Buscar Lab1PDA
set "PROJECT_ROOT=%SCRIPT_DIR%\..\..\.."
cd /d "%PROJECT_ROOT%"
set "PROJECT_ROOT=%CD%"
set "LAB1_DIR=%PROJECT_ROOT%\Lab1PDA"
set "BACKUP_FILE=%LAB1_DIR%\docker\init-db\RespaldoCulturarte.sql"

REM Verificar que existe el archivo de respaldo
if not exist "%BACKUP_FILE%" (
    echo ERROR: No se encontro el archivo de respaldo
    echo Esperado en: %BACKUP_FILE%
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo Archivo de respaldo encontrado: %BACKUP_FILE%
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
    echo Por favor, especifica la ruta manualmente o usa phpMyAdmin
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo MySQL encontrado en: %MYSQL_PATH%
echo.

REM Crear la base de datos si no existe
echo Creando base de datos si no existe...
"%MYSQL_PATH%" -u root -e "CREATE DATABASE IF NOT EXISTS culturarte;" 2>nul
if errorlevel 1 (
    echo Advertencia: No se pudo crear la base de datos automaticamente
    echo Puede que necesites ingresar la contraseña de root
    echo.
    echo Intentando con usuario culturarte...
    "%MYSQL_PATH%" -u culturarte -pculturarte123 -e "CREATE DATABASE IF NOT EXISTS culturarte;" 2>nul
)

REM Crear el usuario culturarte si no existe y otorgar permisos
echo.
echo Configurando usuario y permisos...
echo Creando usuario culturarte si no existe...
"%MYSQL_PATH%" -u root -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>nul
if errorlevel 1 (
    echo Advertencia: No se pudo crear el usuario automaticamente
    echo Puede que el usuario ya exista o necesites ingresar la contraseña de root
)

echo Otorgando permisos al usuario culturarte...
"%MYSQL_PATH%" -u root -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>nul
if errorlevel 1 (
    echo Advertencia: No se pudo otorgar permisos automaticamente
    echo Puede que necesites ingresar la contraseña de root
) else (
    echo Permisos otorgados correctamente
)

echo Aplicando cambios...
"%MYSQL_PATH%" -u root -e "FLUSH PRIVILEGES;" 2>nul

REM Restaurar el respaldo
echo.
echo Restaurando respaldo desde: %BACKUP_FILE%
echo Esto puede tardar unos segundos...
echo.

REM Intentar con root primero (sin contraseña)
"%MYSQL_PATH%" -u root culturarte < "%BACKUP_FILE%" 2>nul
if errorlevel 1 (
    echo No se pudo restaurar con root (puede requerir contraseña)
    echo.
    echo Intentando con usuario culturarte...
    "%MYSQL_PATH%" -u culturarte -pculturarte123 culturarte < "%BACKUP_FILE%" 2>nul
    if errorlevel 1 (
        echo.
        echo ERROR: No se pudo restaurar el respaldo automaticamente
        echo.
        echo OPCIONES:
        echo 1. Usar phpMyAdmin:
        echo    - Abre http://localhost/phpmyadmin
        echo    - Selecciona la base de datos "culturarte"
        echo    - Ve a la pestaña "Importar"
        echo    - Selecciona el archivo: %BACKUP_FILE%
        echo    - Haz clic en "Continuar"
        echo.
        echo 2. Usar la linea de comandos manualmente:
        echo    "%MYSQL_PATH%" -u root -p culturarte ^< "%BACKUP_FILE%"
        echo    (te pedira la contraseña de root)
        echo.
        echo Presiona cualquier tecla para cerrar...
        pause >nul
        exit /b 1
    )
)

echo.
echo ==========================================
echo   Base de datos restaurada exitosamente
echo ==========================================
echo.
echo La base de datos "culturarte" ha sido restaurada desde el respaldo.
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul

