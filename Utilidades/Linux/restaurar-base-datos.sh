#!/bin/bash

# Script para restaurar la base de datos desde el respaldo SQL
# Uso: ./restaurar-base-datos.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "  Restaurando Base de Datos Culturarte"
echo "=========================================="
echo ""

# Obtener directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_DIR="$(cd "$SCRIPT_DIR" && pwd)"

# Buscar Lab1PDA
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
LAB1_DIR="$PROJECT_ROOT/Lab1PDA"
BACKUP_FILE="$LAB1_DIR/docker/init-db/RespaldoCulturarte.sql"

# Verificar que existe el archivo de respaldo
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}ERROR: No se encontró el archivo de respaldo${NC}"
    echo "Esperado en: $BACKUP_FILE"
    echo ""
    echo "Presiona Enter para cerrar..."
    read -r
    exit 1
fi

echo -e "${GREEN}Archivo de respaldo encontrado: $BACKUP_FILE${NC}"
echo ""

# Verificar que MySQL esté corriendo
echo -e "${YELLOW}Verificando que MySQL esté corriendo...${NC}"
if command -v lsof > /dev/null 2>&1; then
    if lsof -Pi :3306 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}MySQL está corriendo en el puerto 3306${NC}"
    else
        echo -e "${RED}ERROR: MySQL no está corriendo en el puerto 3306${NC}"
        echo "Por favor, inicia MySQL"
        echo ""
        echo "Presiona Enter para cerrar..."
        read -r
        exit 1
    fi
elif command -v netstat > /dev/null 2>&1; then
    if netstat -an 2>/dev/null | grep -q ":3306.*LISTEN"; then
        echo -e "${GREEN}MySQL está corriendo en el puerto 3306${NC}"
    else
        echo -e "${RED}ERROR: MySQL no está corriendo en el puerto 3306${NC}"
        echo "Por favor, inicia MySQL"
        echo ""
        echo "Presiona Enter para cerrar..."
        read -r
        exit 1
    fi
else
    echo -e "${YELLOW}No se pudo verificar el puerto, continuando...${NC}"
fi
echo ""

# Buscar mysql
MYSQL_CMD=""
if command -v mysql > /dev/null 2>&1; then
    MYSQL_CMD="mysql"
elif [ -f "/usr/bin/mysql" ]; then
    MYSQL_CMD="/usr/bin/mysql"
elif [ -f "/usr/local/bin/mysql" ]; then
    MYSQL_CMD="/usr/local/bin/mysql"
else
    echo -e "${RED}ERROR: No se encontró el comando mysql${NC}"
    echo "Por favor, instala MySQL o usa phpMyAdmin"
    echo ""
    echo "Presiona Enter para cerrar..."
    read -r
    exit 1
fi

echo -e "${GREEN}MySQL encontrado: $MYSQL_CMD${NC}"
echo ""

# Crear la base de datos si no existe
echo -e "${YELLOW}Creando base de datos si no existe...${NC}"
$MYSQL_CMD -u root -e "CREATE DATABASE IF NOT EXISTS culturarte;" 2>/dev/null || \
$MYSQL_CMD -u culturarte -pculturarte123 -e "CREATE DATABASE IF NOT EXISTS culturarte;" 2>/dev/null || \
echo -e "${YELLOW}Advertencia: No se pudo crear la base de datos automáticamente${NC}"

# Crear el usuario culturarte si no existe y otorgar permisos
echo ""
echo -e "${YELLOW}Configurando usuario y permisos...${NC}"
echo -e "${YELLOW}Creando usuario culturarte si no existe...${NC}"
$MYSQL_CMD -u root -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>/dev/null || \
echo -e "${YELLOW}Advertencia: No se pudo crear el usuario automáticamente (puede que ya exista)${NC}"

echo -e "${YELLOW}Otorgando permisos al usuario culturarte...${NC}"
if $MYSQL_CMD -u root -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>/dev/null; then
    echo -e "${GREEN}Permisos otorgados correctamente${NC}"
else
    echo -e "${YELLOW}Advertencia: No se pudo otorgar permisos automáticamente${NC}"
fi

echo -e "${YELLOW}Aplicando cambios...${NC}"
$MYSQL_CMD -u root -e "FLUSH PRIVILEGES;" 2>/dev/null

# Restaurar el respaldo
echo ""
echo -e "${YELLOW}Restaurando respaldo desde: $BACKUP_FILE${NC}"
echo "Esto puede tardar unos segundos..."
echo ""

# Intentar con root primero
if $MYSQL_CMD -u root culturarte < "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✓ Base de datos restaurada exitosamente${NC}"
elif $MYSQL_CMD -u culturarte -pculturarte123 culturarte < "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✓ Base de datos restaurada exitosamente${NC}"
else
    echo -e "${RED}ERROR: No se pudo restaurar el respaldo automáticamente${NC}"
    echo ""
    echo "OPCIONES:"
    echo "1. Usar phpMyAdmin:"
    echo "   - Abre http://localhost/phpmyadmin"
    echo "   - Selecciona la base de datos 'culturarte'"
    echo "   - Ve a la pestaña 'Importar'"
    echo "   - Selecciona el archivo: $BACKUP_FILE"
    echo "   - Haz clic en 'Continuar'"
    echo ""
    echo "2. Usar la línea de comandos manualmente:"
    echo "   $MYSQL_CMD -u root -p culturarte < \"$BACKUP_FILE\""
    echo "   (te pedirá la contraseña de root)"
    echo ""
    echo "Presiona Enter para cerrar..."
    read -r
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}  Base de datos restaurada exitosamente${NC}"
echo "=========================================="
echo ""
echo "La base de datos 'culturarte' ha sido restaurada desde el respaldo."
echo ""
echo "Presiona Enter para cerrar..."
read -r

