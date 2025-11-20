#!/bin/bash

# Script para iniciar solo los servicios (Servidor Central + Tomcat, SIN Estación de Trabajo)
# Uso: ./iniciar-servicios.sh

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para pausar antes de cerrar (siempre se ejecuta)
pause_before_exit() {
    echo ""
    echo "=========================================="
    echo -e "${YELLOW}Presiona Enter para cerrar...${NC}"
    read -r
}

# Configurar trap para que siempre pause antes de salir
trap pause_before_exit EXIT

echo "=========================================="
echo "  Iniciando Servicios Culturarte"
echo "  (Sin Estación de Trabajo)"
echo "=========================================="
echo ""

# Función para verificar si un puerto está en uso
check_port() {
    # Intentar con netstat (Windows/Git Bash)
    if command -v netstat > /dev/null 2>&1; then
        if netstat -an 2>/dev/null | grep -q ":$1.*LISTEN"; then
            echo -e "${RED}ERROR: El puerto $1 ya está en uso${NC}"
            return 1
        fi
    # Intentar con lsof (Linux/Mac)
    elif command -v lsof > /dev/null 2>&1; then
        if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${RED}ERROR: El puerto $1 ya está en uso${NC}"
            return 1
        fi
    # Si no hay herramientas, intentar con curl/wget
    elif command -v curl > /dev/null 2>&1; then
        if curl -s --connect-timeout 1 http://localhost:$1 > /dev/null 2>&1; then
            echo -e "${YELLOW}ADVERTENCIA: El puerto $1 parece estar en uso${NC}"
        fi
    fi
    return 0
}

# Verificar puertos
echo -e "${YELLOW}Verificando puertos...${NC}"
if ! check_port 9128; then
    echo -e "${RED}Por favor, detén el proceso que está usando el puerto 9128${NC}"
    echo -e "${YELLOW}Puedes usar: ./detener-servicios.sh${NC}"
    exit 1
fi
if ! check_port 8080; then
    echo -e "${RED}Por favor, detén el proceso que está usando el puerto 8080${NC}"
    echo -e "${YELLOW}Puedes usar: ./detener-tomcat.sh o ./detener-tomcat.bat${NC}"
    exit 1
fi
echo -e "${GREEN}Puertos disponibles${NC}"
echo ""

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Convertir a ruta absoluta
SCRIPT_DIR="$(cd "$SCRIPT_DIR" && pwd)"

# Buscar Lab1PDA y Lab2PDA desde la estructura
# El script está en [cualquier_carpeta]/Lab2PDA/Utilidades/Linux/, así que subimos 3 niveles
# para llegar a la carpeta que contiene tanto Lab1PDA como Lab2PDA
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
LAB1_DIR="$PROJECT_ROOT/Lab1PDA"
LAB2_DIR="$PROJECT_ROOT/Lab2PDA"

# Verificar que existen los directorios
if [ ! -d "$LAB1_DIR" ]; then
    echo -e "${RED}ERROR: No se encontró el directorio Lab1PDA${NC}"
    echo -e "${YELLOW}Esperado en: $LAB1_DIR${NC}"
    echo -e "${YELLOW}Asegúrate de que la estructura sea: PDA/Lab1PDA y PDA/Lab2PDA${NC}"
    exit 1
fi

if [ ! -d "$LAB2_DIR" ]; then
    echo -e "${RED}ERROR: No se encontró el directorio Lab2PDA${NC}"
    echo -e "${YELLOW}Esperado en: $LAB2_DIR${NC}"
    echo -e "${YELLOW}Asegúrate de que la estructura sea: PDA/Lab1PDA y PDA/Lab2PDA${NC}"
    exit 1
fi

# Verificar que existen los archivos compilados (en las carpetas individuales)
JAR_FILE="$LAB1_DIR/dist/servidor.jar"
WAR_FILE="$LAB2_DIR/dist/web.war"

# Si no están en dist/, buscar en target/ (compilación directa con Maven)
if [ ! -f "$JAR_FILE" ]; then
    if [ -f "$LAB1_DIR/target/culturarte-app-1.0.0-jar-with-dependencies.jar" ]; then
        JAR_FILE="$LAB1_DIR/target/culturarte-app-1.0.0-jar-with-dependencies.jar"
    fi
fi

if [ ! -f "$WAR_FILE" ]; then
    if [ -f "$LAB2_DIR/target/LabPDAWeb-1.0-SNAPSHOT.war" ]; then
        WAR_FILE="$LAB2_DIR/target/LabPDAWeb-1.0-SNAPSHOT.war"
    fi
fi

if [ ! -f "$JAR_FILE" ] || [ ! -f "$WAR_FILE" ]; then
    echo -e "${RED}ERROR: No se encontraron los archivos compilados${NC}"
    echo ""
    echo -e "${YELLOW}Los siguientes archivos no existen:${NC}"
    [ ! -f "$JAR_FILE" ] && echo -e "${RED}  - servidor.jar (buscado en: $LAB1_DIR/dist/ y $LAB1_DIR/target/)${NC}"
    [ ! -f "$WAR_FILE" ] && echo -e "${RED}  - web.war (buscado en: $LAB2_DIR/dist/ y $LAB2_DIR/target/)${NC}"
    echo ""
    echo -e "${YELLOW}Por favor, compila primero:${NC}"
    echo "  ./compilar-servidor.sh  (para generar servidor.jar)"
    echo "  ./compilar-web.sh       (para generar web.war)"
    echo ""
    echo -e "${YELLOW}O usa el script unificado:${NC}"
    echo "  ./compilar.sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}Archivos compilados encontrados:${NC}"
echo "  - $JAR_FILE"
echo "  - $WAR_FILE"
echo ""

# Iniciar Servidor Central (Web Services)
echo -e "${YELLOW}Iniciando Servidor Central (Web Services en puerto 9128)...${NC}"

# Determinar ruta de log (compatible con Windows)
if [ -d "/tmp" ]; then
    LOG_WS="/tmp/culturarte-ws.log"
else
    LOG_WS="$SCRIPT_DIR/culturarte-ws.log"
fi

# Usar el JAR compilado
# Ejecutar desde Lab1PDA para que uploads/ se resuelva correctamente
cd "$LAB1_DIR"
java -cp "$JAR_FILE" culturarte.presentacion.WSPublicador > "$LOG_WS" 2>&1 &
WS_PID=$!
cd "$SCRIPT_DIR"
echo "Web Services iniciado (PID: $WS_PID)"
echo "Logs en: $LOG_WS"
sleep 3

# Verificar que el Web Service está corriendo
if command -v ps > /dev/null 2>&1; then
    if ! ps -p $WS_PID > /dev/null 2>&1; then
        echo -e "${RED}ERROR: No se pudo iniciar el Web Service${NC}"
        echo "Revisa los logs: $LOG_WS"
        exit 1
    fi
else
    # En Windows, verificar con tasklist o simplemente esperar
    sleep 2
fi
echo -e "${GREEN}Servidor Central iniciado correctamente${NC}"
echo ""

# Iniciar Tomcat (Servidor Web)
echo -e "${YELLOW}Iniciando Tomcat (Servidor Web en puerto 8080)...${NC}"

# Determinar ruta de log (compatible con Windows)
if [ -d "/tmp" ]; then
    LOG_TOMCAT="/tmp/culturarte-tomcat.log"
else
    LOG_TOMCAT="$SCRIPT_DIR/culturarte-tomcat.log"
fi

# Buscar Tomcat instalado en ubicaciones comunes
TOMCAT_HOME=""
TOMCAT_BIN=""

# PRIMERO: Buscar en Lab2PDA/apache-tomcat-10.1.48 (estructura esperada)
if [ -d "$LAB2_DIR/apache-tomcat-10.1.48/bin" ]; then
    TOMCAT_HOME="$LAB2_DIR/apache-tomcat-10.1.48"
elif [ -d "$LAB2_DIR/apache-tomcat-10.1/bin" ]; then
    TOMCAT_HOME="$LAB2_DIR/apache-tomcat-10.1"
elif [ -d "$LAB2_DIR/apache-tomcat-10/bin" ]; then
    TOMCAT_HOME="$LAB2_DIR/apache-tomcat-10"
# SEGUNDO: Buscar en el directorio del script (por compatibilidad)
elif [ -d "$SCRIPT_DIR/apache-tomcat-10.1.48/bin" ]; then
    TOMCAT_HOME="$SCRIPT_DIR/apache-tomcat-10.1.48"
elif [ -d "$SCRIPT_DIR/../apache-tomcat-10.1.48/bin" ]; then
    TOMCAT_HOME="$SCRIPT_DIR/../apache-tomcat-10.1.48"
# TERCERO: Windows - ubicaciones comunes
elif [ -d "/c/Program Files/Apache Software Foundation/Tomcat 10.1" ]; then
    TOMCAT_HOME="/c/Program Files/Apache Software Foundation/Tomcat 10.1"
elif [ -d "/c/Program Files/Apache Software Foundation/Tomcat 10.0" ]; then
    TOMCAT_HOME="/c/Program Files/Apache Software Foundation/Tomcat 10.0"
elif [ -d "/c/Program Files/Apache Software Foundation/Tomcat 10" ]; then
    TOMCAT_HOME="/c/Program Files/Apache Software Foundation/Tomcat 10"
elif [ -d "/c/Program Files (x86)/Apache Software Foundation/Tomcat 10.1" ]; then
    TOMCAT_HOME="/c/Program Files (x86)/Apache Software Foundation/Tomcat 10.1"
# Variable de entorno
elif [ ! -z "$CATALINA_HOME" ]; then
    TOMCAT_HOME="$CATALINA_HOME"
fi

if [ ! -z "$TOMCAT_HOME" ] && [ -d "$TOMCAT_HOME" ]; then
    TOMCAT_BIN="$TOMCAT_HOME/bin"
    TOMCAT_WEBAPPS="$TOMCAT_HOME/webapps"
    
    echo -e "${GREEN}Tomcat encontrado en: $TOMCAT_HOME${NC}"
    
    # Verificar que existe el directorio bin
    if [ ! -d "$TOMCAT_BIN" ]; then
        echo -e "${RED}ERROR: No se encontró el directorio bin en: $TOMCAT_HOME${NC}"
        TOMCAT_HOME=""
    fi
fi

# SIMPLE: Copiar WAR y ejecutar Tomcat (como IntelliJ)
if [ ! -z "$TOMCAT_HOME" ] && [ -d "$TOMCAT_BIN" ]; then
    echo -e "${GREEN}Tomcat encontrado: $TOMCAT_HOME${NC}"
    
    # 1. Copiar WAR a webapps
    if [ -f "$WAR_FILE" ]; then
        echo -e "${YELLOW}Copiando WAR a webapps/...${NC}"
        cp "$WAR_FILE" "$TOMCAT_WEBAPPS/web.war"
        echo -e "${GREEN}✓ WAR copiado${NC}"
    else
        echo -e "${RED}ERROR: No se encontró el WAR. Ejecuta: ./compilar.sh${NC}"
        exit 1
    fi
    
    # 2. Ejecutar Tomcat (igual que IntelliJ)
    cd "$TOMCAT_BIN"
    
    if [ -f "startup.bat" ]; then
        # Windows: ejecutar startup.bat
        # Convertir ruta de Git Bash a Windows (maneja espacios correctamente)
        TOMCAT_HOME_WIN=$(cygpath -w "$TOMCAT_HOME" 2>/dev/null || echo "$TOMCAT_HOME" | sed 's|^/c/|C:|' | sed 's|/|\\|g')
        
        echo -e "${YELLOW}Iniciando Tomcat...${NC}"
        echo -e "${YELLOW}Se abrirá una ventana de CMD - NO la cierres${NC}"
        
        # Crear un script temporal .bat para ejecutar Tomcat (evita problemas con espacios)
        TEMP_BAT="$SCRIPT_DIR/iniciar-tomcat-temp.bat"
        TEMP_BAT_WIN=$(cygpath -w "$TEMP_BAT" 2>/dev/null || echo "$TEMP_BAT" | sed 's|^/c/|C:|' | sed 's|/|\\|g')
        
        cat > "$TEMP_BAT" << EOF
@echo off
setlocal
set "CATALINA_HOME=$TOMCAT_HOME_WIN"
set "CATALINA_BASE=$TOMCAT_HOME_WIN"
cd /d "$TOMCAT_HOME_WIN\\bin"
call startup.bat
EOF
        
        # Ejecutar el script .bat en una ventana nueva
        echo -e "${YELLOW}Iniciando Tomcat en ventana separada...${NC}"
        cmd.exe /c "start \"Tomcat Server\" cmd.exe /k \"$TEMP_BAT_WIN\""
        
        # Dar tiempo para que la ventana se abra
        sleep 3
        
        # Esperar y verificar que Tomcat está escuchando en el puerto 8080
        echo ""
        echo -e "${YELLOW}Esperando a que Tomcat inicie (esto puede tardar 30-60 segundos)...${NC}"
        echo -e "${YELLOW}Revisa la ventana de CMD de Tomcat para ver el progreso${NC}"
        echo ""
        TOMCAT_RESPONDING=false
        MAX_ATTEMPTS=30
        
        if command -v netstat > /dev/null 2>&1; then
            for i in $(seq 1 $MAX_ATTEMPTS); do
                PORT_CHECK=$(netstat -ano 2>/dev/null | grep ":8080" | grep "LISTENING" || echo "")
                if [ ! -z "$PORT_CHECK" ]; then
                    TOMCAT_PID=$(echo "$PORT_CHECK" | awk '{print $NF}' | head -1 | tr -d '\r')
                    TOMCAT_RESPONDING=true
                    break
                fi
                # Mostrar progreso cada 2 intentos
                if [ $((i % 2)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($i/$MAX_ATTEMPTS) - ${NC}\c"
                    echo -e "${YELLOW}Revisa la ventana de CMD de Tomcat${NC}"
                fi
                sleep 2
            done
        else
            # Si no hay netstat, esperar un tiempo fijo
            echo -e "${YELLOW}  Esperando 60 segundos (sin netstat)...${NC}"
            echo -e "${YELLOW}  Revisa la ventana de CMD de Tomcat para ver el progreso${NC}"
            for i in {1..30}; do
                sleep 2
                if [ $((i % 5)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($((i*2))s / 60s)${NC}"
                fi
            done
        fi
        
        if [ "$TOMCAT_RESPONDING" = true ]; then
            echo -e "${GREEN}✓ Tomcat iniciado correctamente (PID: $TOMCAT_PID)${NC}"
            echo -e "${GREEN}  Escuchando en: http://localhost:8080${NC}"
        else
            echo -e "${YELLOW}⚠ No se pudo verificar que Tomcat inició${NC}"
            echo -e "${YELLOW}  Revisa la ventana de CMD que se abrió para ver si hay errores${NC}"
            echo -e "${YELLOW}  O verifica manualmente: http://localhost:8080${NC}"
        fi
        
        # Guardar info para detener después
        if [ -d "/tmp" ]; then
            TOMCAT_INFO="/tmp/culturarte-tomcat-info.txt"
        else
            TOMCAT_INFO="$SCRIPT_DIR/culturarte-tomcat-info.txt"
        fi
        echo "$TOMCAT_HOME" > "$TOMCAT_INFO"
        if [ ! -z "$TOMCAT_PID" ]; then
            echo "$TOMCAT_PID" >> "$TOMCAT_INFO"
        fi
        
    elif [ -f "startup.sh" ]; then
        # Linux/Mac
        ./startup.sh > "$LOG_TOMCAT" 2>&1
        sleep 2
        if command -v ps > /dev/null 2>&1; then
            TOMCAT_PID=$(ps aux | grep "[c]atalina" | grep -v grep | awk '{print $2}' | head -1)
        fi
        echo -e "${GREEN}✓ Tomcat iniciado (PID: $TOMCAT_PID)${NC}"
    fi
fi

if [ -z "$TOMCAT_HOME" ] || [ ! -d "$TOMCAT_BIN" ]; then
    echo -e "${RED}ERROR: No se encontró Tomcat instalado${NC}"
    echo -e "${YELLOW}Instala Tomcat en: $LAB2_DIR/apache-tomcat-10.1.48${NC}"
    echo -e "${YELLOW}O configura la variable de entorno CATALINA_HOME${NC}"
    exit 1
fi

echo ""

# Resumen
echo ""
echo "=========================================="
echo -e "${GREEN}  Servicios iniciados correctamente${NC}"
echo "=========================================="
echo ""
echo -e "${GREEN}Servicios disponibles:${NC}"
echo "  - Web Services: http://localhost:9128/culturarteWS"
if [ ! -z "$TOMCAT_HOME" ] && [ -d "$TOMCAT_HOME" ]; then
    echo "  - Servidor Web: http://localhost:8080/web"
    echo "  - HTML App Manager: http://localhost:8080/manager/html"
    echo -e "${YELLOW}    (Usuario: admin / Contraseña: admin)${NC}"
else
    echo "  - Servidor Web: http://localhost:8080/LabPDAWeb"
fi
echo ""
echo -e "${YELLOW}NOTA IMPORTANTE:${NC}"
if [ ! -z "$TOMCAT_HOME" ] && [ -d "$TOMCAT_HOME" ]; then
    echo -e "${YELLOW}  La URL correcta es: http://localhost:8080/web${NC}"
else
    echo -e "${YELLOW}  La URL correcta es: http://localhost:8080/LabPDAWeb${NC}"
    echo -e "${YELLOW}  NO uses: http://localhost:8080/LabPDAWeb_war${NC}"
fi
echo ""
echo -e "${YELLOW}NOTA: Si Tomcat no responde, espera unos segundos más.${NC}"
echo -e "${YELLOW}      Puede tardar en iniciar completamente.${NC}"
echo ""
echo -e "${GREEN}Procesos en ejecución:${NC}"
echo "  - Web Services (PID: $WS_PID)"
if [ ! -z "$TOMCAT_PID" ]; then
    echo "  - Tomcat (PID: $TOMCAT_PID)"
else
    echo "  - Tomcat (en ventana de CMD separada)"
fi
echo ""
echo -e "${YELLOW}Para detener los servicios:${NC}"
echo "  ./detener-servicios.sh"
echo ""
echo "=========================================="
echo ""

# Guardar PIDs en archivo para poder detenerlos después
if [ -d "/tmp" ]; then
    PIDS_FILE="/tmp/culturarte-pids.txt"
else
    PIDS_FILE="$SCRIPT_DIR/culturarte-pids.txt"
fi
echo "$WS_PID" > "$PIDS_FILE"
if [ ! -z "$TOMCAT_PID" ]; then
    echo "$TOMCAT_PID" >> "$PIDS_FILE"
fi

# Pausa adicional para que el usuario pueda leer todo
echo ""
echo "=========================================="
echo -e "${YELLOW}IMPORTANTE:${NC}"
echo -e "${YELLOW}  - NO cierres esta ventana${NC}"
echo -e "${YELLOW}  - NO cierres la ventana de CMD de Tomcat${NC}"
echo -e "${YELLOW}  - Para detener todo, usa: ./detener-servicios.sh${NC}"
echo "=========================================="
echo ""

# Desactivar el trap para que no pause dos veces
trap - EXIT
echo -e "${GREEN}Presiona Enter para cerrar esta ventana (los servicios seguirán corriendo)...${NC}"
read -r

