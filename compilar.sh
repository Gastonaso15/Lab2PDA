#!/bin/bash

# Script de compilación para generar los archivos JAR y WAR del sistema Culturarte
# Genera: servidor.jar, web.war
# Cumple con los requisitos de la sección 7.8 de la especificación
# Uso: ./compilar.sh

set -e  # Salir si hay algún error

echo "=========================================="
echo "  Compilando Sistema Culturarte"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAB1_DIR="$SCRIPT_DIR/Lab1PDA"
LAB2_DIR="$SCRIPT_DIR/Lab2PDA"
OUTPUT_DIR="$SCRIPT_DIR/dist"

# Verificar que existen los directorios
if [ ! -d "$LAB1_DIR" ]; then
    echo -e "${RED}ERROR: No se encuentra el directorio Lab1PDA${NC}"
    exit 1
fi

if [ ! -d "$LAB2_DIR" ]; then
    echo -e "${RED}ERROR: No se encuentra el directorio Lab2PDA${NC}"
    exit 1
fi

# Crear directorio de salida
echo -e "${YELLOW}Creando directorio de salida...${NC}"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}Directorio creado: $OUTPUT_DIR${NC}"
echo ""

# ==========================================
# 1. Configurar archivos de propiedades en ~/.Culturarte/
# ==========================================
echo -e "${YELLOW}Configurando archivos de propiedades en ~/.Culturarte/...${NC}"
USER_HOME="$HOME"
CULTURARTE_DIR="$USER_HOME/.Culturarte"
mkdir -p "$CULTURARTE_DIR"

# Copiar config.propiedades si no existe
if [ ! -f "$CULTURARTE_DIR/config.propiedades" ]; then
    if [ -f "$LAB1_DIR/config.propiedades" ]; then
        cp "$LAB1_DIR/config.propiedades" "$CULTURARTE_DIR/config.propiedades"
        echo -e "${GREEN}Archivo config.propiedades copiado a ~/.Culturarte/${NC}"
    else
        # Crear archivo por defecto
        cat > "$CULTURARTE_DIR/config.propiedades" << EOF
# Configuración del Servidor Central
# URL base para los Web Services SOAP
servidor.central.base_url=http://localhost:9128/culturarteWS
EOF
        echo -e "${GREEN}Archivo config.propiedades creado en ~/.Culturarte/${NC}"
    fi
else
    echo -e "${YELLOW}Archivo config.propiedades ya existe en ~/.Culturarte/${NC}"
fi

# Crear archivo de configuración de base de datos si no existe
if [ ! -f "$CULTURARTE_DIR/database.properties" ]; then
    cat > "$CULTURARTE_DIR/database.properties" << EOF
# Configuración de Base de Datos
# Estas propiedades se usan para configurar la conexión a la base de datos MySQL
db.url=jdbc:mysql://localhost:3306/culturarte
db.user=culturarte
db.password=culturarte123
db.driver=com.mysql.cj.jdbc.Driver
hibernate.hbm2ddl.auto=update
hibernate.show_sql=true
hibernate.format_sql=true
hibernate.dialect=org.hibernate.dialect.MySQLDialect
hibernate.connection.autocommit=false
EOF
    echo -e "${GREEN}Archivo database.properties creado en ~/.Culturarte/${NC}"
else
    echo -e "${YELLOW}Archivo database.properties ya existe en ~/.Culturarte/${NC}"
fi

echo -e "${GREEN}Configuración lista en: $CULTURARTE_DIR${NC}"
echo ""

# ==========================================
# 2. Compilar Lab1PDA y generar servidor.jar
# ==========================================
echo -e "${YELLOW}Compilando Lab1PDA (Servidor Central)...${NC}"
cd "$LAB1_DIR"

# Limpiar compilaciones anteriores (no fallar si hay archivos bloqueados)
echo -e "${YELLOW}Limpiando compilaciones anteriores...${NC}"
mvn clean -q -Dmaven.clean.failOnError=false || echo -e "${YELLOW}Advertencia: Algunos archivos no pudieron eliminarse (puede que estén en uso). Continuando...${NC}"

# Compilar y generar JAR con dependencias
echo -e "${YELLOW}Compilando y generando servidor.jar...${NC}"
if ! mvn package -q -DskipTests; then
    echo -e "${RED}ERROR: Falló la compilación de Lab1PDA${NC}"
    exit 1
fi

# Buscar el JAR generado (puede ser con o sin dependencias)
# El maven-assembly-plugin genera: culturarte-app-1.0.0-jar-with-dependencies.jar
JAR_FILE=""
if [ -f "$LAB1_DIR/target/culturarte-app-1.0.0-jar-with-dependencies.jar" ]; then
    JAR_FILE="$LAB1_DIR/target/culturarte-app-1.0.0-jar-with-dependencies.jar"
elif [ -f "$LAB1_DIR/target/culturarte-app-1.0.0.jar" ]; then
    echo -e "${RED}ERROR: Se necesita un JAR con dependencias. Verifica la configuración de maven-assembly-plugin${NC}"
    exit 1
else
    echo -e "${RED}ERROR: No se encontró el JAR generado${NC}"
    exit 1
fi

# Copiar y renombrar a servidor.jar
cp "$JAR_FILE" "$OUTPUT_DIR/servidor.jar"
echo -e "${GREEN}✓ servidor.jar generado en: $OUTPUT_DIR/servidor.jar${NC}"
echo ""

# ==========================================
# 2.5. Iniciar servidor central temporalmente para compilar Lab2PDA
# ==========================================
echo -e "${YELLOW}Iniciando servidor central temporalmente (necesario para compilar Lab2PDA)...${NC}"
echo -e "${YELLOW}Lab2PDA necesita generar clientes de Web Services desde los WSDL${NC}"

# Verificar si el servidor ya está corriendo
SERVER_RUNNING=false
if command -v curl > /dev/null 2>&1; then
    if curl -s --connect-timeout 2 http://localhost:9128/culturarteWS/usuarios?wsdl > /dev/null 2>&1; then
        SERVER_RUNNING=true
        echo -e "${GREEN}Servidor central ya está corriendo${NC}"
    fi
elif command -v wget > /dev/null 2>&1; then
    if wget -q --spider --timeout=2 http://localhost:9128/culturarteWS/usuarios?wsdl 2>/dev/null; then
        SERVER_RUNNING=true
        echo -e "${GREEN}Servidor central ya está corriendo${NC}"
    fi
fi

# Si no está corriendo, iniciarlo en background
STARTED_SERVER=false
if [ "$SERVER_RUNNING" = false ]; then
    echo -e "${YELLOW}Iniciando servidor central en segundo plano...${NC}"
    
    # Iniciar el servidor en background
    cd "$LAB1_DIR"
    # Usar un archivo de log en el directorio temporal del sistema
    if [ -d "/tmp" ]; then
        LOG_FILE="/tmp/culturarte-ws.log"
    else
        # Windows o sistemas sin /tmp
        LOG_FILE="$OUTPUT_DIR/ws-server.log"
    fi
    java -cp "$JAR_FILE" culturarte.presentacion.WSPublicador > "$LOG_FILE" 2>&1 &
    WS_PID=$!
    STARTED_SERVER=true
    echo -e "${YELLOW}Servidor iniciado (PID: $WS_PID)${NC}"
    
    echo -e "${YELLOW}Esperando a que los Web Services estén disponibles...${NC}"
    
    # Esperar hasta 30 segundos a que el servidor esté listo
    MAX_WAIT=30
    WAIT_TIME=0
    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        if command -v curl > /dev/null 2>&1; then
            if curl -s --connect-timeout 2 http://localhost:9128/culturarteWS/usuarios?wsdl > /dev/null 2>&1; then
                echo -e "${GREEN}Servidor central listo!${NC}"
                break
            fi
        elif command -v wget > /dev/null 2>&1; then
            if wget -q --spider --timeout=2 http://localhost:9128/culturarteWS/usuarios?wsdl 2>/dev/null; then
                echo -e "${GREEN}Servidor central listo!${NC}"
                break
            fi
        else
            # Si no hay curl ni wget, esperar un tiempo fijo
            sleep 5
            echo -e "${YELLOW}Esperando... (${WAIT_TIME}s/${MAX_WAIT}s)${NC}"
        fi
        sleep 1
        WAIT_TIME=$((WAIT_TIME + 1))
    done
    
    if [ $WAIT_TIME -ge $MAX_WAIT ]; then
        echo -e "${RED}ERROR: El servidor central no respondió a tiempo${NC}"
        if [ "$STARTED_SERVER" = true ]; then
            kill $WS_PID 2>/dev/null || true
        fi
        exit 1
    fi
    
    # Dar un poco más de tiempo para que todos los servicios estén listos
    sleep 2
fi

# ==========================================
# 3. Compilar Lab2PDA y generar web.war
# ==========================================
echo -e "${YELLOW}Compilando Lab2PDA (Servidor Web)...${NC}"
cd "$LAB2_DIR"

# Limpiar compilaciones anteriores (no fallar si hay archivos bloqueados)
echo -e "${YELLOW}Limpiando compilaciones anteriores...${NC}"
mvn clean -q -Dmaven.clean.failOnError=false || echo -e "${YELLOW}Advertencia: Algunos archivos no pudieron eliminarse (puede que estén en uso). Continuando...${NC}"

# Compilar y generar WAR
echo -e "${YELLOW}Compilando y generando web.war...${NC}"

# Compilar
if ! mvn package -q -DskipTests; then
    echo ""
    echo -e "${RED}ERROR: Falló la compilación de Lab2PDA${NC}"
    echo -e "${YELLOW}Verifica los logs de Maven arriba para ver el error específico${NC}"
    # Detener el servidor si lo iniciamos nosotros
    if [ "$STARTED_SERVER" = true ]; then
        echo -e "${YELLOW}Deteniendo servidor central...${NC}"
        kill $WS_PID 2>/dev/null || true
    fi
    exit 1
fi

# Buscar el WAR generado
if [ -f "$LAB2_DIR/target/LabPDAWeb-1.0-SNAPSHOT.war" ]; then
    WAR_FILE="$LAB2_DIR/target/LabPDAWeb-1.0-SNAPSHOT.war"
    cp "$WAR_FILE" "$OUTPUT_DIR/web.war"
    echo -e "${GREEN}✓ web.war generado en: $OUTPUT_DIR/web.war${NC}"
else
    echo -e "${RED}ERROR: No se encontró el WAR generado${NC}"
    echo -e "${YELLOW}Verifica los logs de Maven arriba para ver el error específico${NC}"
    # Detener el servidor si lo iniciamos nosotros
    if [ "$STARTED_SERVER" = true ]; then
        echo -e "${YELLOW}Deteniendo servidor central...${NC}"
        kill $WS_PID 2>/dev/null || true
    fi
    exit 1
fi

# Detener el servidor si lo iniciamos nosotros
if [ "$STARTED_SERVER" = true ]; then
    echo ""
    echo -e "${YELLOW}Deteniendo servidor central temporal...${NC}"
    kill $WS_PID 2>/dev/null || true
    sleep 1
    echo -e "${GREEN}Servidor central detenido${NC}"
fi
echo ""

# ==========================================
# Resumen
# ==========================================
echo "=========================================="
echo -e "${GREEN}  Compilación completada exitosamente${NC}"
echo "=========================================="
echo ""
echo "Archivos generados en: $OUTPUT_DIR"
echo ""
if ls "$OUTPUT_DIR"/*.jar "$OUTPUT_DIR"/*.war 2>/dev/null | grep -q .; then
    ls -lh "$OUTPUT_DIR"/*.jar "$OUTPUT_DIR"/*.war 2>/dev/null | awk '{print "  ✓ " $9 " (" $5 ")"}'
else
    echo -e "${RED}ERROR: No se generaron archivos${NC}"
    exit 1
fi
echo ""
echo "Archivos de configuración en: $CULTURARTE_DIR"
if ls "$CULTURARTE_DIR"/*.properties "$CULTURARTE_DIR"/config.propiedades 2>/dev/null | grep -q .; then
    ls -lh "$CULTURARTE_DIR"/*.properties "$CULTURARTE_DIR"/config.propiedades 2>/dev/null | awk '{print "  ✓ " $9}'
else
    echo -e "${YELLOW}  (ningún archivo de configuración encontrado)${NC}"
fi
echo ""
echo "=========================================="
echo ""
echo -e "${GREEN}✓ servidor.jar: Contiene el Servidor Central y la Estación de Trabajo${NC}"
echo -e "${GREEN}✓ web.war: Contiene la aplicación web para desplegar en Tomcat${NC}"
echo ""
echo "Para ejecutar los servicios:"
echo "  Servidor Central: java -jar $OUTPUT_DIR/servidor.jar"
echo "  Solo Web Services: java -cp $OUTPUT_DIR/servidor.jar culturarte.presentacion.WSPublicador"
echo "  Desplegar en Tomcat: copiar $OUTPUT_DIR/web.war a \$CATALINA_HOME/webapps/"
echo ""
echo "=========================================="
