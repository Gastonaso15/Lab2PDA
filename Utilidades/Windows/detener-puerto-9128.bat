@echo off
REM Script para detener procesos en el puerto 9128 (Web Services)
REM Uso: detener-puerto-9128.bat

echo ==========================================
echo   Deteniendo procesos en puerto 9128
echo ==========================================
echo.

echo Buscando procesos en el puerto 9128...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9128 ^| findstr LISTENING') do (
    set PID=%%a
    echo Proceso encontrado en puerto 9128: PID %%a
    echo Forzando detencion...
    taskkill /F /PID %%a
    if errorlevel 1 (
        echo ERROR: No se pudo detener el proceso %%a
    ) else (
        echo Proceso %%a detenido correctamente
    )
)

echo.
echo Verificando si el puerto 9128 esta libre...
timeout /t 2 /nobreak >nul
netstat -ano | findstr :9128
if errorlevel 1 (
    echo Puerto 9128 liberado correctamente
) else (
    echo ADVERTENCIA: El puerto 9128 aun esta en uso
)

echo.
echo Presiona cualquier tecla para cerrar...
pause >nul

