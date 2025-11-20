#!/bin/bash

# Script para detener procesos en el puerto 9128 (Web Services)
# Uso: ./detener-puerto-9128.sh

echo "=========================================="
echo "  Deteniendo procesos en puerto 9128"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Buscar procesos en el puerto 9128
echo -e "${YELLOW}Buscando procesos en el puerto 9128...${NC}"

if command -v netstat > /dev/null 2>&1; then
    # Windows o sistemas con netstat
    PIDS=$(netstat -ano | grep :9128 | grep LISTENING | awk '{print $NF}' | sort -u)
    for PID in $PIDS; do
        if [ ! -z "$PID" ] && [ "$PID" != "PID" ]; then
            echo -e "${YELLOW}Proceso encontrado en puerto 9128: PID $PID${NC}"
            if command -v taskkill > /dev/null 2>&1; then
                # Windows
                echo -e "${YELLOW}Forzando detención...${NC}"
                taskkill /F /PID $PID 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Proceso $PID detenido correctamente${NC}"
                else
                    echo -e "${RED}ERROR: No se pudo detener el proceso $PID${NC}"
                fi
            elif command -v kill > /dev/null 2>&1; then
                # Linux/Mac
                echo -e "${YELLOW}Forzando detención...${NC}"
                kill -9 $PID 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Proceso $PID detenido correctamente${NC}"
                else
                    echo -e "${RED}ERROR: No se pudo detener el proceso $PID${NC}"
                fi
            fi
        fi
    done
elif command -v lsof > /dev/null 2>&1; then
    # Linux/Mac con lsof
    PIDS=$(lsof -ti :9128)
    for PID in $PIDS; do
        if [ ! -z "$PID" ]; then
            echo -e "${YELLOW}Proceso encontrado en puerto 9128: PID $PID${NC}"
            echo -e "${YELLOW}Forzando detención...${NC}"
            kill -9 $PID 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Proceso $PID detenido correctamente${NC}"
            else
                echo -e "${RED}ERROR: No se pudo detener el proceso $PID${NC}"
            fi
        fi
    done
fi

echo ""
echo -e "${YELLOW}Verificando si el puerto 9128 está libre...${NC}"
sleep 2

if command -v netstat > /dev/null 2>&1; then
    if netstat -ano | grep :9128 | grep LISTENING > /dev/null 2>&1; then
        echo -e "${RED}ADVERTENCIA: El puerto 9128 aún está en uso${NC}"
    else
        echo -e "${GREEN}Puerto 9128 liberado correctamente${NC}"
    fi
elif command -v lsof > /dev/null 2>&1; then
    if lsof -ti :9128 > /dev/null 2>&1; then
        echo -e "${RED}ADVERTENCIA: El puerto 9128 aún está en uso${NC}"
    else
        echo -e "${GREEN}Puerto 9128 liberado correctamente${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Presiona Enter para cerrar...${NC}"
read -r

