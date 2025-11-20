@echo off
REM Script de compilación para generar los archivos JAR y WAR del sistema Culturarte
REM Genera: servidor.jar, web.war
REM Uso: compilar.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Compilando Sistema Culturarte
echo ==========================================
echo.

REM Obtener directorio del script
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Buscar Lab1PDA y Lab2PDA desde la estructura
REM El script está en [cualquier_carpeta]/Lab2PDA/Utilidades/Windows/, así que subimos 3 niveles
REM para llegar a la carpeta que contiene tanto Lab1PDA como Lab2PDA
set "PROJECT_ROOT=%SCRIPT_DIR%\..\..\.."
REM Convertir a ruta absoluta
cd /d "%PROJECT_ROOT%"
set "PROJECT_ROOT=%CD%"
set "LAB1_DIR=%PROJECT_ROOT%\Lab1PDA"
set "LAB2_DIR=%PROJECT_ROOT%\Lab2PDA"

REM Mostrar información de depuración
echo Informacion de depuracion:
echo   Script ejecutado desde: %SCRIPT_DIR%
echo   Directorio raiz del proyecto: %PROJECT_ROOT%
echo   Buscando Lab1PDA en: %LAB1_DIR%
echo   Buscando Lab2PDA en: %LAB2_DIR%
echo.

REM Verificar que existen los directorios
if not exist "%LAB1_DIR%" (
    echo ERROR: No se encuentra el directorio Lab1PDA
    echo Esperado en: %LAB1_DIR%
    echo Asegurate de que la estructura sea: PDA\Lab1PDA y PDA\Lab2PDA
    echo.
    echo Estructura actual del directorio raiz:
    dir /b "%PROJECT_ROOT%" 2>nul
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

if not exist "%LAB2_DIR%" (
    echo ERROR: No se encuentra el directorio Lab2PDA
    echo Esperado en: %LAB2_DIR%
    echo Asegurate de que la estructura sea: PDA\Lab1PDA y PDA\Lab2PDA
    echo.
    echo Estructura actual del directorio raiz:
    dir /b "%PROJECT_ROOT%" 2>nul
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

echo Directorios encontrados correctamente
echo.

REM ==========================================
REM 1. Configurar archivos de propiedades en %USERPROFILE%\.Culturarte\
REM ==========================================
echo Configurando archivos de propiedades en %USERPROFILE%\.Culturarte\...
set "CULTURARTE_DIR=%USERPROFILE%\.Culturarte"
if not exist "%CULTURARTE_DIR%" mkdir "%CULTURARTE_DIR%"

REM Copiar config.propiedades si no existe
if not exist "%CULTURARTE_DIR%\config.propiedades" (
    if exist "%LAB1_DIR%\config.propiedades" (
        copy /Y "%LAB1_DIR%\config.propiedades" "%CULTURARTE_DIR%\config.propiedades" >nul
        echo Archivo config.propiedades copiado a %CULTURARTE_DIR%
    ) else (
        REM Crear archivo por defecto
        (
            echo # Configuracion del Servidor Central
            echo # URL base para los Web Services SOAP
            echo servidor.central.base_url=http://localhost:9128/culturarteWS
        ) > "%CULTURARTE_DIR%\config.propiedades"
        echo Archivo config.propiedades creado en %CULTURARTE_DIR%
    )
) else (
    echo Archivo config.propiedades ya existe en %CULTURARTE_DIR%
)

REM Crear archivo de configuración de base de datos si no existe
if not exist "%CULTURARTE_DIR%\database.properties" (
    (
        echo # Configuracion de Base de Datos
        echo # Estas propiedades se usan para configurar la conexion a la base de datos MySQL
        echo db.url=jdbc:mysql://localhost:3306/culturarte
        echo db.user=culturarte
        echo db.password=culturarte123
        echo db.driver=com.mysql.cj.jdbc.Driver
        echo hibernate.hbm2ddl.auto=update
        echo hibernate.show_sql=true
        echo hibernate.format_sql=true
        echo hibernate.dialect=org.hibernate.dialect.MySQLDialect
        echo hibernate.connection.autocommit=false
    ) > "%CULTURARTE_DIR%\database.properties"
    echo Archivo database.properties creado en %CULTURARTE_DIR%
) else (
    echo Archivo database.properties ya existe en %CULTURARTE_DIR%
)

echo Configuracion lista en: %CULTURARTE_DIR%
echo.

REM ==========================================
REM 2. Compilar Lab1PDA y generar servidor.jar
REM ==========================================
echo Compilando Lab1PDA (Servidor Central)...
cd /d "%LAB1_DIR%"

REM Limpiar compilaciones anteriores
echo Limpiando compilaciones anteriores...
call mvn clean -q -Dmaven.clean.failOnError=false 2>nul || echo Advertencia: Algunos archivos no pudieron eliminarse (puede que esten en uso). Continuando...

REM Compilar y generar JAR con dependencias
echo Compilando y generando servidor.jar...
call mvn package -q -DskipTests
if errorlevel 1 (
    echo ERROR: Fallo la compilacion de Lab1PDA
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

REM Buscar el JAR generado
set "JAR_FILE="
if exist "%LAB1_DIR%\target\culturarte-app-1.0.0-jar-with-dependencies.jar" (
    set "JAR_FILE=%LAB1_DIR%\target\culturarte-app-1.0.0-jar-with-dependencies.jar"
) else if exist "%LAB1_DIR%\target\culturarte-app-1.0.0.jar" (
    echo ERROR: Se necesita un JAR con dependencias. Verifica la configuracion de maven-assembly-plugin
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
) else (
    echo ERROR: No se encontro el JAR generado
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

REM Crear directorio dist en Lab1PDA si no existe
set "LAB1_DIST=%LAB1_DIR%\dist"
if not exist "%LAB1_DIST%" mkdir "%LAB1_DIST%"

REM Copiar y renombrar a servidor.jar
copy /Y "%JAR_FILE%" "%LAB1_DIST%\servidor.jar" >nul
echo servidor.jar generado en: %LAB1_DIST%\servidor.jar
echo.

REM ==========================================
REM 2.5. Iniciar servidor central temporalmente para compilar Lab2PDA
REM ==========================================
echo Iniciando servidor central temporalmente (necesario para compilar Lab2PDA)...
echo Lab2PDA necesita generar clientes de Web Services desde los WSDL
echo.

REM Verificar si el servidor ya está corriendo
set "SERVER_RUNNING=0"
netstat -ano | findstr :9128 | findstr LISTENING >nul
if %errorlevel% == 0 (
    set "SERVER_RUNNING=1"
    echo Servidor central ya esta corriendo
)

REM Si no está corriendo, iniciarlo en background
set "STARTED_SERVER=0"
if %SERVER_RUNNING% == 0 (
    echo Iniciando servidor central en segundo plano...
    cd /d "%LAB1_DIR%"
    start /B java -cp "%JAR_FILE%" culturarte.presentacion.WSPublicador > "%LAB2_DIR%\ws-server.log" 2>&1
    set "STARTED_SERVER=1"
    echo Servidor iniciado
    echo.
    echo Esperando a que los Web Services esten disponibles...
    
    REM Esperar hasta 30 segundos a que el servidor esté listo
    set "MAX_WAIT=30"
    set "WAIT_TIME=0"
    set "SERVER_READY=0"
    
    for /L %%i in (1,1,%MAX_WAIT%) do (
        timeout /t 1 /nobreak >nul
        netstat -ano | findstr :9128 | findstr LISTENING >nul
        if %errorlevel% == 0 (
            set "SERVER_READY=1"
            goto :server_ready
        )
        set /a "WAIT_TIME=%%i"
        if !WAIT_TIME! == 5 (
            echo   Esperando... (!WAIT_TIME!s/%MAX_WAIT%s)
        )
        if !WAIT_TIME! == 10 (
            echo   Esperando... (!WAIT_TIME!s/%MAX_WAIT%s)
        )
        if !WAIT_TIME! == 20 (
            echo   Esperando... (!WAIT_TIME!s/%MAX_WAIT%s)
        )
    )
    
    :server_ready
    if %SERVER_READY% == 0 (
        echo ERROR: El servidor central no respondio a tiempo
        echo.
        echo Presiona cualquier tecla para cerrar...
        pause >nul
        exit /b 1
    )
    
    echo Servidor central listo!
    timeout /t 2 /nobreak >nul
)

REM ==========================================
REM 3. Compilar Lab2PDA y generar web.war
REM ==========================================
echo Compilando Lab2PDA (Servidor Web)...
cd /d "%LAB2_DIR%"

REM Limpiar compilaciones anteriores
echo Limpiando compilaciones anteriores...
call mvn clean -q -Dmaven.clean.failOnError=false 2>nul || echo Advertencia: Algunos archivos no pudieron eliminarse (puede que esten en uso). Continuando...

REM Compilar y generar WAR
echo Compilando y generando web.war...
call mvn package -q -DskipTests
if errorlevel 1 (
    echo.
    echo ERROR: Fallo la compilacion de Lab2PDA
    echo Verifica los logs de Maven arriba para ver el error especifico
    REM Detener el servidor si lo iniciamos nosotros
    if %STARTED_SERVER% == 1 (
        echo Deteniendo servidor central...
        REM Buscar y detener el proceso Java
        for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST ^| findstr /C:"PID:"') do (
            set "JAVA_PID=%%a"
            for /f "tokens=*" %%b in ('wmic process where "ProcessId=!JAVA_PID!" get CommandLine /format:list ^| findstr /C:"WSPublicador"') do (
                taskkill /F /PID !JAVA_PID! >nul 2>&1
            )
        )
    )
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

REM Crear directorio dist en Lab2PDA si no existe
set "LAB2_DIST=%LAB2_DIR%\dist"
if not exist "%LAB2_DIST%" mkdir "%LAB2_DIST%"

REM Buscar el WAR generado
set "WAR_FILE="
if exist "%LAB2_DIR%\target\LabPDAWeb-1.0-SNAPSHOT.war" (
    set "WAR_FILE=%LAB2_DIR%\target\LabPDAWeb-1.0-SNAPSHOT.war"
    copy /Y "%WAR_FILE%" "%LAB2_DIST%\web.war" >nul
    echo web.war generado en: %LAB2_DIST%\web.war
) else if exist "%LAB2_DIR%\target\web.war" (
    set "WAR_FILE=%LAB2_DIR%\target\web.war"
    copy /Y "%WAR_FILE%" "%LAB2_DIST%\web.war" >nul
    echo web.war generado en: %LAB2_DIST%\web.war
) else (
    echo ERROR: No se encontro el WAR generado
    echo Verifica los logs de Maven arriba para ver el error especifico
    REM Detener el servidor si lo iniciamos nosotros
    if %STARTED_SERVER% == 1 (
        echo Deteniendo servidor central...
        for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST ^| findstr /C:"PID:"') do (
            set "JAVA_PID=%%a"
            for /f "tokens=*" %%b in ('wmic process where "ProcessId=!JAVA_PID!" get CommandLine /format:list ^| findstr /C:"WSPublicador"') do (
                taskkill /F /PID !JAVA_PID! >nul 2>&1
            )
        )
    )
    echo.
    echo Presiona cualquier tecla para cerrar...
    pause >nul
    exit /b 1
)

REM Detener el servidor si lo iniciamos nosotros
if %STARTED_SERVER% == 1 (
    echo.
    echo Deteniendo servidor central temporal...
    for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST ^| findstr /C:"PID:"') do (
        set "JAVA_PID=%%a"
        for /f "tokens=*" %%b in ('wmic process where "ProcessId=!JAVA_PID!" get CommandLine /format:list ^| findstr /C:"WSPublicador"') do (
            taskkill /F /PID !JAVA_PID! >nul 2>&1
        )
    )
    timeout /t 1 /nobreak >nul
    echo Servidor central detenido
)
echo.

REM ==========================================
REM Resumen
REM ==========================================
echo ==========================================
echo   Compilacion completada exitosamente
echo ==========================================
echo.
echo Archivos generados:
echo.
if exist "%LAB1_DIST%\servidor.jar" (
    for %%A in ("%LAB1_DIST%\servidor.jar") do echo   servidor.jar ^(%%~zA bytes^)
) else (
    echo ERROR: servidor.jar no se genero
)
if exist "%LAB2_DIST%\web.war" (
    for %%A in ("%LAB2_DIST%\web.war") do echo   web.war ^(%%~zA bytes^)
) else (
    echo ERROR: web.war no se genero
)
echo.
echo Archivos de configuracion en: %CULTURARTE_DIR%
if exist "%CULTURARTE_DIR%\config.propiedades" (
    echo   config.propiedades
)
if exist "%CULTURARTE_DIR%\database.properties" (
    echo   database.properties
)
echo.
echo ==========================================
echo.
echo servidor.jar: Contiene el Servidor Central y la Estacion de Trabajo
echo web.war: Contiene la aplicacion web para desplegar en Tomcat
echo.
echo Para ejecutar los servicios:
echo   Servidor Central: java -jar %LAB1_DIST%\servidor.jar
echo   Solo Web Services: java -cp %LAB1_DIST%\servidor.jar culturarte.presentacion.WSPublicador
echo   Desplegar en Tomcat: copiar %LAB2_DIST%\web.war a %CATALINA_HOME%\webapps\
echo.
echo ==========================================
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul

