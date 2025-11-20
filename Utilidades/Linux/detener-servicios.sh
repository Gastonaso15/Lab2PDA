#!/bin/bash

# Script para detener todos los servicios de Culturarte
# Uso: ./detener-servicios.sh

echo "=========================================="
echo "  Deteniendo Servicios Culturarte"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Determinar ruta del archivo de PIDs (compatible con Windows)
if [ -d "/tmp" ]; then
    PIDS_FILE="/tmp/culturarte-pids.txt"
else
    PIDS_FILE="$SCRIPT_DIR/culturarte-pids.txt"
fi

# Verificar si hay información de Tomcat instalado
if [ -d "/tmp" ]; then
    TOMCAT_INFO="/tmp/culturarte-tomcat-info.txt"
else
    TOMCAT_INFO="$SCRIPT_DIR/culturarte-tomcat-info.txt"
fi

# Detener Tomcat instalado si existe
if [ -f "$TOMCAT_INFO" ]; then
    TOMCAT_HOME=$(cat "$TOMCAT_INFO" 2>/dev/null)
    if [ ! -z "$TOMCAT_HOME" ] && [ -d "$TOMCAT_HOME" ]; then
        TOMCAT_BIN="$TOMCAT_HOME/bin"
        echo -e "${YELLOW}Deteniendo Tomcat instalado en: $TOMCAT_HOME${NC}"
        
        if [ -f "$TOMCAT_BIN/shutdown.sh" ]; then
            cd "$TOMCAT_BIN"
            ./shutdown.sh > /dev/null 2>&1
            echo -e "${GREEN}Tomcat detenido${NC}"
        elif [ -f "$TOMCAT_BIN/shutdown.bat" ]; then
            cd "$TOMCAT_BIN"
            cmd.exe //c shutdown.bat > /dev/null 2>&1
            echo -e "${GREEN}Tomcat detenido${NC}"
        else
            echo -e "${YELLOW}No se encontró shutdown.sh/bat, intentando detener por proceso...${NC}"
        fi
    fi
    rm -f "$TOMCAT_INFO"
fi

# Leer PIDs del archivo
if [ -f "$PIDS_FILE" ]; then
    while read pid; do
        if [ ! -z "$pid" ]; then
            if command -v ps > /dev/null 2>&1; then
                if ps -p $pid > /dev/null 2>&1; then
                    echo -e "${YELLOW}Deteniendo proceso (PID: $pid)...${NC}"
                    kill $pid 2>/dev/null || true
                    sleep 1
                    if ! ps -p $pid > /dev/null 2>&1; then
                        echo -e "${GREEN}Proceso $pid detenido${NC}"
                    else
                        echo -e "${RED}Forzando detención del proceso $pid...${NC}"
                        kill -9 $pid 2>/dev/null || true
                    fi
                fi
            else
                # En Windows, intentar con taskkill
                if command -v taskkill > /dev/null 2>&1; then
                    taskkill /F /PID $pid > /dev/null 2>&1 && echo -e "${GREEN}Proceso $pid detenido${NC}" || true
                else
                    # Último recurso: intentar kill
                    kill $pid 2>/dev/null || true
                fi
            fi
        fi
    done < "$PIDS_FILE"
    rm -f "$PIDS_FILE"
    echo -e "${GREEN}Servicios detenidos${NC}"
else
    echo -e "${YELLOW}No se encontró archivo de PIDs${NC}"
    echo "Intentando detener procesos manualmente..."
    
    # Intentar detener por nombre
    if command -v pkill > /dev/null 2>&1; then
        pkill -f "WSPublicador" 2>/dev/null && echo -e "${GREEN}Web Services detenido${NC}" || true
        pkill -f "EstacionDeTrabajo" 2>/dev/null && echo -e "${GREEN}Estación de Trabajo detenida${NC}" || true
        pkill -f "tomcat" 2>/dev/null && echo -e "${GREEN}Tomcat detenido${NC}" || true
    elif command -v taskkill > /dev/null 2>&1; then
        taskkill /F /IM java.exe /FI "WINDOWTITLE eq *WSPublicador*" > /dev/null 2>&1 && echo -e "${GREEN}Web Services detenido${NC}" || true
        taskkill /F /IM java.exe /FI "WINDOWTITLE eq *EstacionDeTrabajo*" > /dev/null 2>&1 && echo -e "${GREEN}Estación de Trabajo detenida${NC}" || true
        # Detener procesos Java relacionados con Tomcat
        taskkill /F /IM java.exe /FI "COMMANDLINE eq *catalina*" > /dev/null 2>&1 && echo -e "${GREEN}Tomcat detenido${NC}" || true
    fi
fi

echo ""

