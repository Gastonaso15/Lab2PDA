@echo off
REM Script para detener todos los servicios de Culturarte
REM Uso: detener-servicios.bat

setlocal enabledelayedexpansion

echo ==========================================
echo   Deteniendo Servicios Culturarte
echo ==========================================
echo.

REM Obtener directorio del script
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Determinar ruta del archivo de PIDs
set "PIDS_FILE=%SCRIPT_DIR%\culturarte-pids.txt"

REM Verificar si hay información de Tomcat instalado
set "TOMCAT_INFO=%SCRIPT_DIR%\culturarte-tomcat-info.txt"

REM Detener Tomcat instalado si existe
if exist "%TOMCAT_INFO%" (
    set /p TOMCAT_HOME=<"%TOMCAT_INFO%"
    if not "!TOMCAT_HOME!"=="" (
        if exist "!TOMCAT_HOME!\bin\shutdown.bat" (
            echo Deteniendo Tomcat instalado en: !TOMCAT_HOME!
            cd /d "!TOMCAT_HOME!\bin"
            call shutdown.bat >nul 2>&1
            echo Tomcat detenido
        ) else (
            echo No se encontro shutdown.bat, intentando detener por proceso...
        )
    )
    del "%TOMCAT_INFO%" >nul 2>&1
)

REM Leer PIDs del archivo
if exist "%PIDS_FILE%" (
    for /f "usebackq delims=" %%a in ("%PIDS_FILE%") do (
        set "PID=%%a"
        if not "!PID!"=="" (
            echo Deteniendo proceso (PID: !PID!)...
            taskkill /F /PID !PID! >nul 2>&1
            if errorlevel 1 (
                echo No se pudo detener el proceso !PID! (puede que ya no exista)
            ) else (
                echo Proceso !PID! detenido
            )
        )
    )
    del "%PIDS_FILE%" >nul 2>&1
    echo Servicios detenidos
) else (
    echo No se encontro archivo de PIDs
    echo Intentando detener procesos manualmente...
    
    REM Intentar detener por nombre de proceso
    taskkill /F /IM java.exe /FI "WINDOWTITLE eq *WSPublicador*" >nul 2>&1
    if errorlevel 1 (
        echo No se encontro proceso WSPublicador
    ) else (
        echo Web Services detenido
    )
    
    taskkill /F /IM java.exe /FI "WINDOWTITLE eq *EstacionDeTrabajo*" >nul 2>&1
    if errorlevel 1 (
        echo No se encontro proceso EstacionDeTrabajo
    ) else (
        echo Estacion de Trabajo detenida
    )
    
    REM Detener procesos Java relacionados con Tomcat
    for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq java.exe" /FO LIST ^| findstr /C:"PID:"') do (
        set "JAVA_PID=%%a"
        REM Verificar si es un proceso de Tomcat (buscando en la línea de comandos)
        for /f "tokens=*" %%b in ('wmic process where "ProcessId=!JAVA_PID!" get CommandLine /format:list ^| findstr /C:"catalina"') do (
            echo Deteniendo proceso Java de Tomcat (PID: !JAVA_PID!)...
            taskkill /F /PID !JAVA_PID! >nul 2>&1
            if errorlevel 1 (
                echo No se pudo detener el proceso !JAVA_PID!
            ) else (
                echo Tomcat detenido
            )
        )
    )
)

REM Detener procesos en puertos específicos como respaldo
echo.
echo Verificando puertos...
netstat -ano | findstr :9128 | findstr LISTENING >nul
if %errorlevel% == 0 (
    echo Advertencia: El puerto 9128 aun esta en uso
    echo Puedes usar: detener-puerto-9128.bat
)

netstat -ano | findstr :8080 | findstr LISTENING >nul
if %errorlevel% == 0 (
    echo Advertencia: El puerto 8080 aun esta en uso
    echo Puedes cerrar manualmente la ventana de CMD de Tomcat
)

echo.
echo ==========================================
echo   Proceso de detencion completado
echo ==========================================
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul

