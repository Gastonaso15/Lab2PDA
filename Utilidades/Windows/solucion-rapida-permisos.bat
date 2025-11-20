@echo off
REM Solución rápida para otorgar permisos sin reparar tablas
REM Uso: solucion-rapida-permisos.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Solucion Rapida: Otorgar Permisos
echo ==========================================
echo.
echo Este script otorga permisos directamente sin reparar tablas
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
echo   Configurando permisos directamente
echo ==========================================
echo.
echo IMPORTANTE: Este script NO repara tablas, solo otorga permisos
echo Si hay corrupcion, los permisos pueden no persistir
echo.
echo Por favor, ingresa la contraseña de root cuando se solicite
echo (Si no tienes contraseña, presiona Enter)
echo.
pause

REM Crear usuario si no existe (sin verificar primero)
echo.
echo Creando/actualizando usuario culturarte...
"%MYSQL_PATH%" -u root -p -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>nul
if errorlevel 1 (
    echo Intentando sin contraseña...
    "%MYSQL_PATH%" -u root -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>nul
)

REM Otorgar permisos directamente
echo.
echo Otorgando permisos...
"%MYSQL_PATH%" -u root -p -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>nul
if errorlevel 1 (
    echo Intentando sin contraseña...
    "%MYSQL_PATH%" -u root -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>nul
)

REM NO hacer FLUSH PRIVILEGES si hay corrupción
echo.
echo ==========================================
echo   IMPORTANTE: No se ejecuto FLUSH PRIVILEGES
echo ==========================================
echo.
echo Debido a la corrupcion de las tablas, FLUSH PRIVILEGES puede fallar.
echo.
echo SOLUCION: Reinicia MySQL desde XAMPP
echo   1. Abre el panel de control de XAMPP
echo   2. Deten MySQL (Stop)
echo   3. Espera 5 segundos
echo   4. Inicia MySQL nuevamente (Start)
echo.
echo Esto aplicara los permisos sin necesidad de FLUSH PRIVILEGES
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul


