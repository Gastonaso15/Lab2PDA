@echo off
REM Script para iniciar TODO el sistema (Servidor Central + Estación de Trabajo + Tomcat)
REM Uso: iniciar-todo.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Iniciando Sistema Culturarte Completo
echo ==========================================
echo.

REM Obtener directorio del script
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
REM Buscar Lab1PDA y Lab2PDA desde la estructura
REM El script está en [cualquier_carpeta]/Lab2PDA/Utilidades/Windows/, así que subimos 3 niveles
REM para llegar a la carpeta que contiene tanto Lab1PDA como Lab2PDA
set "PROJECT_ROOT=%SCRIPT_DIR%\..\..\.."
cd /d "%PROJECT_ROOT%"
set "PROJECT_ROOT=%CD%"
set "LAB1_DIR=%PROJECT_ROOT%\Lab1PDA"
set "LAB2_DIR=%PROJECT_ROOT%\Lab2PDA"

REM Verificar puertos
echo Verificando puertos...
netstat -ano | findstr :9128 | findstr LISTENING >nul
if %errorlevel% == 0 (
    echo ERROR: El puerto 9128 ya esta en uso
    echo Por favor, deten el proceso que esta usando el puerto 9128
    echo Puedes usar: detener-puerto-9128.bat
    pause
    exit /b 1
)

netstat -ano | findstr :8080 | findstr LISTENING >nul
if %errorlevel% == 0 (
    echo ERROR: El puerto 8080 ya esta en uso
    echo Por favor, deten el proceso que esta usando el puerto 8080
    echo Puedes usar: detener-puerto-9128.bat o detener-servicios.bat
    pause
    exit /b 1
)

echo Puertos disponibles
echo.

REM Verificar que existen los directorios
if not exist "%LAB1_DIR%" (
    echo ERROR: No se encontro el directorio Lab1PDA
    echo Esperado en: %LAB1_DIR%
    echo Asegurate de que la estructura sea: PDA\Lab1PDA y PDA\Lab2PDA
    pause
    exit /b 1
)

if not exist "%LAB2_DIR%" (
    echo ERROR: No se encontro el directorio Lab2PDA
    echo Esperado en: %LAB2_DIR%
    echo Asegurate de que la estructura sea: PDA\Lab1PDA y PDA\Lab2PDA
    pause
    exit /b 1
)

REM Buscar archivos compilados (primero en dist/ raiz, luego en subdirectorios)
set "JAR_FILE="
set "WAR_FILE="

REM Buscar servidor.jar
if exist "%SCRIPT_DIR%\dist\servidor.jar" (
    set "JAR_FILE=%SCRIPT_DIR%\dist\servidor.jar"
) else if exist "%LAB1_DIR%\dist\servidor.jar" (
    set "JAR_FILE=%LAB1_DIR%\dist\servidor.jar"
) else if exist "%LAB1_DIR%\target\culturarte-app-1.0.0-jar-with-dependencies.jar" (
    set "JAR_FILE=%LAB1_DIR%\target\culturarte-app-1.0.0-jar-with-dependencies.jar"
)

REM Buscar web.war
if exist "%SCRIPT_DIR%\dist\web.war" (
    set "WAR_FILE=%SCRIPT_DIR%\dist\web.war"
) else if exist "%LAB2_DIR%\dist\web.war" (
    set "WAR_FILE=%LAB2_DIR%\dist\web.war"
) else if exist "%LAB2_DIR%\target\web.war" (
    set "WAR_FILE=%LAB2_DIR%\target\web.war"
) else if exist "%LAB2_DIR%\target\LabPDAWeb-1.0-SNAPSHOT.war" (
    set "WAR_FILE=%LAB2_DIR%\target\LabPDAWeb-1.0-SNAPSHOT.war"
)

if not exist "%JAR_FILE%" (
    echo ERROR: No se encontro el archivo compilado
    echo   - servidor.jar
    echo   Buscado en: dist\, %LAB1_DIR%\dist\, %LAB1_DIR%\target\
    echo.
    echo Por favor, compila primero: compilar.sh
    echo   O ejecuta: cd Lab1PDA ^&^& mvn clean package
    pause
    exit /b 1
)

if not exist "%WAR_FILE%" (
    echo ERROR: No se encontro el archivo compilado
    echo   - web.war
    echo   Buscado en: dist\, %LAB2_DIR%\dist\, %LAB2_DIR%\target\
    echo.
    echo Por favor, compila primero: compilar.sh
    echo   O ejecuta: cd Lab2PDA ^&^& mvn clean package
    pause
    exit /b 1
)

echo Archivos compilados encontrados:
echo   - %JAR_FILE%
echo   - %WAR_FILE%
echo.

REM Iniciar Servidor Central (Web Services)
echo Iniciando Servidor Central (Web Services en puerto 9128)...
set "LOG_WS=%SCRIPT_DIR%\culturarte-ws.log"

cd /d "%LAB1_DIR%"
start /B java -cp "%JAR_FILE%" culturarte.presentacion.WSPublicador > "%LOG_WS%" 2>&1
cd /d "%SCRIPT_DIR%"

timeout /t 3 /nobreak >nul

REM Obtener PID del proceso Java que inició el Web Service
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9128 ^| findstr LISTENING') do (
    set "WS_PID=%%a"
    goto :ws_pid_found
)
:ws_pid_found

echo Web Services iniciado
if not "!WS_PID!"=="" (
    echo PID: !WS_PID!
)
echo Logs en: %LOG_WS%
echo Servidor Central iniciado correctamente
echo.

REM Iniciar Estación de Trabajo
echo Iniciando Estación de Trabajo...
set "LOG_ESTACION=%SCRIPT_DIR%\culturarte-estacion.log"

cd /d "%LAB1_DIR%"
start /B java -jar "%JAR_FILE%" > "%LOG_ESTACION%" 2>&1
cd /d "%SCRIPT_DIR%"

timeout /t 2 /nobreak >nul
echo Estación de Trabajo iniciada
echo Logs en: %LOG_ESTACION%
echo Estación de Trabajo iniciada correctamente
echo.

REM Iniciar Tomcat
echo Iniciando Tomcat (Servidor Web en puerto 8080)...
set "LOG_TOMCAT=%SCRIPT_DIR%\culturarte-tomcat.log"

REM Buscar Tomcat
set "TOMCAT_HOME="
REM PRIMERO: Buscar en Lab2PDA/apache-tomcat-10.1.48 (estructura esperada)
if exist "%LAB2_DIR%\apache-tomcat-10.1.48\bin\startup.bat" (
    set "TOMCAT_HOME=%LAB2_DIR%\apache-tomcat-10.1.48"
) else if exist "%LAB2_DIR%\apache-tomcat-10.1\bin\startup.bat" (
    set "TOMCAT_HOME=%LAB2_DIR%\apache-tomcat-10.1"
) else if exist "%LAB2_DIR%\apache-tomcat-10\bin\startup.bat" (
    set "TOMCAT_HOME=%LAB2_DIR%\apache-tomcat-10"
REM SEGUNDO: Buscar en el directorio del script (por compatibilidad)
) else if exist "%SCRIPT_DIR%\apache-tomcat-10.1.48\bin\startup.bat" (
    set "TOMCAT_HOME=%SCRIPT_DIR%\apache-tomcat-10.1.48"
REM TERCERO: Variable de entorno
) else if not "%CATALINA_HOME%"=="" (
    set "TOMCAT_HOME=%CATALINA_HOME%"
)

if "%TOMCAT_HOME%"=="" (
    echo ERROR: No se encontro Tomcat instalado
    echo Instala Tomcat en: %LAB2_DIR%\apache-tomcat-10.1.48
    echo O configura la variable de entorno CATALINA_HOME
    pause
    exit /b 1
)

echo Tomcat encontrado en: %TOMCAT_HOME%
set "TOMCAT_WEBAPPS=%TOMCAT_HOME%\webapps"
set "TOMCAT_BIN=%TOMCAT_HOME%\bin"

REM Copiar WAR a webapps
if exist "%WAR_FILE%" (
    echo Copiando web.war a webapps/...
    copy /Y "%WAR_FILE%" "%TOMCAT_WEBAPPS%\web.war" >nul
    echo web.war copiado
    echo NOTA: Para usar HTML App Manager, accede a: http://localhost:8080/manager/html
) else (
    echo ERROR: No se encontro el WAR. Ejecuta: compilar.sh
    pause
    exit /b 1
)

REM Iniciar Tomcat
echo.
echo Iniciando Tomcat...
echo Se abrira una ventana de CMD - NO la cierres
echo.

REM Crear script temporal para iniciar Tomcat (evita problemas con espacios en rutas)
set "TEMP_BAT=%SCRIPT_DIR%\iniciar-tomcat-temp.bat"
(
echo @echo off
echo setlocal
echo set "CATALINA_HOME=%TOMCAT_HOME%"
echo set "CATALINA_BASE=%TOMCAT_HOME%"
echo cd /d "%TOMCAT_BIN%"
echo call startup.bat
) > "%TEMP_BAT%"

REM Ejecutar el script temporal en una ventana nueva
start "Tomcat Server" cmd /k "%TEMP_BAT%"

timeout /t 3 /nobreak >nul

REM Esperar a que Tomcat inicie
echo Esperando a que Tomcat inicie (esto puede tardar 30-60 segundos)...
echo Revisa la ventana de CMD de Tomcat para ver el progreso
echo.

set "TOMCAT_RESPONDING=0"
set "MAX_ATTEMPTS=30"

for /L %%i in (1,1,%MAX_ATTEMPTS%) do (
    netstat -ano | findstr :8080 | findstr LISTENING >nul
    if %errorlevel% == 0 (
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
            set "TOMCAT_PID=%%a"
        )
        set "TOMCAT_RESPONDING=1"
        goto :tomcat_ready
    )
    
    set /a "modulo=%%i %% 3"
    if !modulo! == 0 (
        echo   Esperando... (%%i/%MAX_ATTEMPTS%)
    )
    
    timeout /t 2 /nobreak >nul
)

:tomcat_ready
if %TOMCAT_RESPONDING% == 1 (
    echo.
    echo Tomcat iniciado correctamente (PID: !TOMCAT_PID!)
    echo   Escuchando en: http://localhost:8080
    echo   HTML App Manager: http://localhost:8080/manager/html
) else (
    echo.
    echo ADVERTENCIA: No se pudo verificar que Tomcat inicio
    echo   Revisa la ventana de CMD que se abrio para ver si hay errores
    echo   O verifica manualmente: http://localhost:8080
)

REM Guardar info para detener después
set "TOMCAT_INFO=%SCRIPT_DIR%\culturarte-tomcat-info.txt"
echo %TOMCAT_HOME% > "%TOMCAT_INFO%"
if not "!TOMCAT_PID!"=="" (
    echo !TOMCAT_PID! >> "%TOMCAT_INFO%"
)

REM Guardar PIDs (se guardarán cuando se detecten)
set "PIDS_FILE=%SCRIPT_DIR%\culturarte-pids.txt"
REM Los PIDs se guardarán en detener-todo.bat o detener-servicios.bat

echo.
echo ==========================================
echo   Sistema iniciado correctamente
echo ==========================================
echo.
echo Servicios disponibles:
echo   - Web Services: http://localhost:9128/culturarteWS
echo   - Servidor Web: http://localhost:8080/web
echo   - HTML App Manager: http://localhost:8080/manager/html
echo     (Usuario: admin / Contraseña: admin)
echo.
echo Procesos en ejecucion:
if not "!WS_PID!"=="" (
    echo   - Web Services (PID: !WS_PID!)
)
echo   - Estacion de Trabajo (en proceso Java)
if not "!TOMCAT_PID!"=="" (
    echo   - Tomcat (PID: !TOMCAT_PID!)
) else (
    echo   - Tomcat (en ventana de CMD separada)
)
echo.
echo Para detener los servicios:
echo   detener-todo.bat
echo.
echo NOTA IMPORTANTE:
echo   - NO cierres esta ventana
echo   - NO cierres la ventana de CMD de Tomcat
echo   - Los servicios seguiran corriendo despues de cerrar esta ventana
echo.
echo ==========================================
echo.
echo Presiona Enter para cerrar esta ventana (los servicios seguiran corriendo)...
pause >nul

