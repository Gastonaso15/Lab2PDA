#!/bin/bash

# Script para iniciar TODO el sistema (Servidor Central + Estación de Trabajo + Tomcat)
# Uso: ./iniciar-todo.sh

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
echo "  Iniciando Sistema Culturarte Completo"
echo "=========================================="
echo ""

# Función para detener procesos que usan un puerto
stop_port() {
    local PORT=$1
    local PID=""
    local STOPPED=false
    
    echo -e "${YELLOW}Verificando puerto $PORT...${NC}"
    
    # Intentar con lsof (Linux/Mac) - más confiable
    if command -v lsof > /dev/null 2>&1; then
        PID=$(lsof -Pi :$PORT -sTCP:LISTEN -t 2>/dev/null | head -1)
        if [ ! -z "$PID" ]; then
            echo -e "${YELLOW}  Puerto $PORT en uso por proceso PID: $PID${NC}"
            echo -e "${YELLOW}  Deteniendo proceso...${NC}"
            kill -9 "$PID" 2>/dev/null && STOPPED=true || kill "$PID" 2>/dev/null && STOPPED=true
            if [ "$STOPPED" = true ]; then
                sleep 1
                # Verificar que se detuvo
                if ! lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
                    echo -e "${GREEN}  ✓ Proceso detenido${NC}"
                    return 0
                fi
            fi
        fi
    # Intentar con netstat (Windows/Git Bash)
    elif command -v netstat > /dev/null 2>&1; then
        # En Windows, netstat muestra el PID de forma diferente
        if netstat -ano 2>/dev/null | grep -q ":$PORT.*LISTENING"; then
            PID=$(netstat -ano 2>/dev/null | grep ":$PORT.*LISTENING" | awk '{print $NF}' | head -1 | tr -d '\r')
            if [ ! -z "$PID" ] && [ "$PID" != "0" ]; then
                echo -e "${YELLOW}  Puerto $PORT en uso por proceso PID: $PID${NC}"
                echo -e "${YELLOW}  Deteniendo proceso...${NC}"
                # En Windows, usar taskkill si está disponible
                if command -v taskkill > /dev/null 2>&1; then
                    taskkill /F /PID "$PID" >/dev/null 2>&1 && STOPPED=true
                else
                    kill -9 "$PID" 2>/dev/null && STOPPED=true || kill "$PID" 2>/dev/null && STOPPED=true
                fi
                if [ "$STOPPED" = true ]; then
                    sleep 1
                    echo -e "${GREEN}  ✓ Proceso detenido${NC}"
                    return 0
                fi
            fi
        fi
    # Intentar con fuser (Linux)
    elif command -v fuser > /dev/null 2>&1; then
        PID=$(fuser $PORT/tcp 2>/dev/null | awk '{print $1}' | head -1)
        if [ ! -z "$PID" ]; then
            echo -e "${YELLOW}  Puerto $PORT en uso por proceso PID: $PID${NC}"
            echo -e "${YELLOW}  Deteniendo proceso...${NC}"
            kill -9 "$PID" 2>/dev/null && STOPPED=true || kill "$PID" 2>/dev/null && STOPPED=true
            if [ "$STOPPED" = true ]; then
                sleep 1
                echo -e "${GREEN}  ✓ Proceso detenido${NC}"
                return 0
            fi
        fi
    fi
    
    # Si llegamos aquí, el puerto no está en uso o no se pudo detener
    if [ "$STOPPED" = false ]; then
        # Verificar una vez más si el puerto está libre
        if command -v lsof > /dev/null 2>&1; then
            if ! lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
                echo -e "${GREEN}  ✓ Puerto $PORT disponible${NC}"
                return 0
            fi
        elif command -v netstat > /dev/null 2>&1; then
            if ! netstat -an 2>/dev/null | grep -q ":$PORT.*LISTEN"; then
                echo -e "${GREEN}  ✓ Puerto $PORT disponible${NC}"
                return 0
            fi
        else
            # Si no hay herramientas, asumir que está disponible
            echo -e "${GREEN}  ✓ Puerto $PORT disponible${NC}"
            return 0
        fi
        
        # Si todavía está en uso y no se pudo detener
        echo -e "${RED}  ✗ No se pudo detener el proceso en el puerto $PORT${NC}"
        return 1
    fi
    
    return 0
}

# Verificar y liberar puertos automáticamente
echo -e "${YELLOW}Verificando y liberando puertos...${NC}"
echo ""

# Detener procesos en puerto 9128
if ! stop_port 9128; then
    echo -e "${RED}ERROR: No se pudo liberar el puerto 9128${NC}"
    echo -e "${YELLOW}Intenta detener los servicios manualmente: ./detener-servicios.sh${NC}"
    exit 1
fi

# Detener procesos en puerto 8080
if ! stop_port 8080; then
    echo -e "${RED}ERROR: No se pudo liberar el puerto 8080${NC}"
    echo -e "${YELLOW}Intenta detener Tomcat manualmente: ./detener-tomcat.sh${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Puertos disponibles${NC}"
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
    # Buscar web.war (nombre final configurado en pom.xml)
    if [ -f "$LAB2_DIR/target/web.war" ]; then
        WAR_FILE="$LAB2_DIR/target/web.war"
    elif [ -f "$LAB2_DIR/target/LabPDAWeb-1.0-SNAPSHOT.war" ]; then
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
    LOG_ESTACION="/tmp/culturarte-estacion.log"
    LOG_TOMCAT="/tmp/culturarte-tomcat.log"
else
    LOG_WS="$SCRIPT_DIR/culturarte-ws.log"
    LOG_ESTACION="$SCRIPT_DIR/culturarte-estacion.log"
    LOG_TOMCAT="$SCRIPT_DIR/culturarte-tomcat.log"
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

# Iniciar Estación de Trabajo
echo -e "${YELLOW}Iniciando Estación de Trabajo...${NC}"
# Usar el JAR compilado
# Ejecutar desde Lab1PDA para que uploads/ se resuelva correctamente
cd "$LAB1_DIR"
java -jar "$JAR_FILE" > "$LOG_ESTACION" 2>&1 &
ESTACION_PID=$!
cd "$SCRIPT_DIR"
echo "Estación de Trabajo iniciada (PID: $ESTACION_PID)"
echo "Logs en: $LOG_ESTACION"
sleep 2
echo -e "${GREEN}Estación de Trabajo iniciada${NC}"
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

# Usar Tomcat instalado (requerido para HTML App Manager según la letra del profesor)
if [ ! -z "$TOMCAT_HOME" ] && [ -d "$TOMCAT_BIN" ]; then
    echo -e "${GREEN}Usando Tomcat instalado (requerido para HTML App Manager)${NC}"
    
    # 1. Copiar WAR a webapps
    if [ -f "$WAR_FILE" ]; then
        echo -e "${YELLOW}Copiando web.war a webapps/...${NC}"
        cp "$WAR_FILE" "$TOMCAT_WEBAPPS/web.war"
        echo -e "${GREEN}✓ web.war copiado${NC}"
        echo -e "${YELLOW}NOTA: Para usar HTML App Manager, accede a: http://localhost:8080/manager/html${NC}"
    else
        echo -e "${RED}ERROR: No se encontró el WAR. Ejecuta: ./compilar.sh${NC}"
        exit 1
    fi
    
    # 2. Ejecutar Tomcat
    cd "$TOMCAT_BIN"
    
    if [ -f "startup.sh" ]; then
        # Linux/Mac: ejecutar startup.sh
        echo -e "${YELLOW}Iniciando Tomcat...${NC}"
        ./startup.sh > "$LOG_TOMCAT" 2>&1
        sleep 2
        
        # Verificar que Tomcat está escuchando en el puerto 8080
        echo -e "${YELLOW}Esperando a que Tomcat inicie...${NC}"
        TOMCAT_RESPONDING=false
        MAX_ATTEMPTS=30
        
        if command -v lsof > /dev/null 2>&1; then
            for i in $(seq 1 $MAX_ATTEMPTS); do
                if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
                    TOMCAT_PID=$(lsof -Pi :8080 -sTCP:LISTEN -t | head -1)
                    TOMCAT_RESPONDING=true
                    break
                fi
                # Mostrar progreso cada 3 intentos
                if [ $((i % 3)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($i/$MAX_ATTEMPTS)${NC}"
                fi
                sleep 2
            done
        elif command -v ps > /dev/null 2>&1; then
            for i in $(seq 1 $MAX_ATTEMPTS); do
                TOMCAT_PID=$(ps aux | grep "[c]atalina" | grep -v grep | awk '{print $2}' | head -1)
                if [ ! -z "$TOMCAT_PID" ]; then
                    TOMCAT_RESPONDING=true
                    break
                fi
                # Mostrar progreso cada 3 intentos
                if [ $((i % 3)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($i/$MAX_ATTEMPTS)${NC}"
                fi
                sleep 2
            done
        else
            # Si no hay herramientas, esperar un tiempo fijo
            echo -e "${YELLOW}  Esperando 60 segundos...${NC}"
            for i in {1..30}; do
                sleep 2
                if [ $((i % 5)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($((i*2))s)${NC}"
                fi
            done
            TOMCAT_RESPONDING=true  # Asumir que inició
        fi
        
        if [ "$TOMCAT_RESPONDING" = true ] && [ ! -z "$TOMCAT_PID" ]; then
            echo -e "${GREEN}✓ Tomcat iniciado correctamente (PID: $TOMCAT_PID)${NC}"
            echo -e "${GREEN}  Escuchando en: http://localhost:8080${NC}"
            echo -e "${YELLOW}  HTML App Manager: http://localhost:8080/manager/html${NC}"
        else
            echo -e "${YELLOW}⚠ No se pudo verificar que Tomcat inició${NC}"
            echo -e "${YELLOW}  Revisa los logs en: $LOG_TOMCAT${NC}"
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
        
    elif [ -f "startup.bat" ]; then
        # Windows (Git Bash): ejecutar startup.bat
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
        
        # Esperar y verificar que Tomcat está escuchando en el puerto 8080
        echo -e "${YELLOW}Esperando a que Tomcat inicie...${NC}"
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
                # Mostrar progreso cada 3 intentos
                if [ $((i % 3)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($i/$MAX_ATTEMPTS)${NC}"
                fi
                sleep 2
            done
        else
            # Si no hay netstat, esperar un tiempo fijo
            echo -e "${YELLOW}  Esperando 60 segundos (sin netstat)...${NC}"
            for i in {1..30}; do
                sleep 2
                if [ $((i % 5)) -eq 0 ]; then
                    echo -e "${YELLOW}  Esperando... ($((i*2))s)${NC}"
                fi
            done
        fi
        
        if [ "$TOMCAT_RESPONDING" = true ]; then
            echo -e "${GREEN}✓ Tomcat iniciado correctamente (PID: $TOMCAT_PID)${NC}"
            echo -e "${GREEN}  Escuchando en: http://localhost:8080${NC}"
            echo -e "${YELLOW}  HTML App Manager: http://localhost:8080/manager/html${NC}"
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
    fi
else
    echo -e "${RED}ERROR: No se encontró Tomcat instalado${NC}"
    echo -e "${YELLOW}Según la letra del profesor, se requiere Tomcat instalado para usar HTML App Manager${NC}"
    echo -e "${YELLOW}Instala Tomcat en: $LAB2_DIR/apache-tomcat-10.1.48${NC}"
    echo -e "${YELLOW}O configura la variable de entorno CATALINA_HOME${NC}"
    echo ""
    echo -e "${YELLOW}Alternativa temporal: Puedes usar el script desplegar.sh después de iniciar Tomcat manualmente${NC}"
    TOMCAT_PID=""
fi
echo ""

# Resumen
echo "=========================================="
echo -e "${GREEN}  Sistema iniciado correctamente${NC}"
echo "=========================================="
echo ""
echo "Servicios disponibles:"
echo "  - Web Services: http://localhost:9128/culturarteWS"
echo "  - Servidor Web: http://localhost:8080/web"
echo "  - HTML App Manager: http://localhost:8080/manager/html"
echo ""
echo -e "${YELLOW}NOTA: Si Tomcat no responde, espera unos segundos más.${NC}"
echo -e "${YELLOW}      Puede tardar en iniciar completamente.${NC}"
echo ""
echo "Procesos en ejecución:"
echo "  - Web Services (PID: $WS_PID)"
if [ ! -z "$ESTACION_PID" ]; then
    echo "  - Estación de Trabajo (PID: $ESTACION_PID)"
fi
if [ ! -z "$TOMCAT_PID" ]; then
    echo "  - Tomcat (PID: $TOMCAT_PID)"
fi
echo ""
echo "Para detener los servicios, ejecuta:"
echo "  kill $WS_PID"
if [ ! -z "$ESTACION_PID" ]; then
    echo "  kill $ESTACION_PID"
fi
if [ ! -z "$TOMCAT_PID" ]; then
    echo "  kill $TOMCAT_PID"
fi
echo ""
echo "O usa el script: ./detener-todo.sh"
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
if [ ! -z "$ESTACION_PID" ]; then
    echo "$ESTACION_PID" >> "$PIDS_FILE"
fi
if [ ! -z "$TOMCAT_PID" ]; then
    echo "$TOMCAT_PID" >> "$PIDS_FILE"
fi

# Desactivar el trap para que no pause dos veces
trap - EXIT
echo -e "${GREEN}Presiona Enter para cerrar...${NC}"
read -r

