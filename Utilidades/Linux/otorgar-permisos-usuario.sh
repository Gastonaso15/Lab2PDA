#!/bin/bash

# Script para otorgar permisos al usuario culturarte en la base de datos
# Uso: ./otorgar-permisos-usuario.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "  Configurando Usuario y Permisos MySQL"
echo "=========================================="
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
    echo "Por favor, instala MySQL"
    echo ""
    echo "Presiona Enter para cerrar..."
    read -r
    exit 1
fi

echo -e "${GREEN}MySQL encontrado: $MYSQL_CMD${NC}"
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

# Crear la base de datos si no existe
echo -e "${YELLOW}Creando base de datos si no existe...${NC}"
if $MYSQL_CMD -u root -e "CREATE DATABASE IF NOT EXISTS culturarte;" 2>/dev/null; then
    echo -e "${GREEN}Base de datos creada o ya existe${NC}"
else
    echo -e "${YELLOW}Advertencia: No se pudo crear la base de datos automáticamente${NC}"
    echo "Por favor, ingresa la contraseña de root cuando se solicite:"
    $MYSQL_CMD -u root -p -e "CREATE DATABASE IF NOT EXISTS culturarte;"
fi

# Crear el usuario culturarte si no existe
echo ""
echo -e "${YELLOW}Creando usuario culturarte si no existe...${NC}"
if $MYSQL_CMD -u root -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';" 2>/dev/null; then
    echo -e "${GREEN}Usuario creado o ya existe${NC}"
else
    echo -e "${YELLOW}Advertencia: No se pudo crear el usuario automáticamente${NC}"
    echo "Por favor, ingresa la contraseña de root cuando se solicite:"
    $MYSQL_CMD -u root -p -e "CREATE USER IF NOT EXISTS 'culturarte'@'localhost' IDENTIFIED BY 'culturarte123';"
fi

# Otorgar permisos
echo ""
echo -e "${YELLOW}Otorgando permisos al usuario culturarte...${NC}"
if $MYSQL_CMD -u root -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';" 2>/dev/null; then
    echo -e "${GREEN}Permisos otorgados correctamente${NC}"
else
    echo -e "${RED}ERROR: No se pudo otorgar permisos automáticamente${NC}"
    echo "Por favor, ingresa la contraseña de root cuando se solicite:"
    $MYSQL_CMD -u root -p -e "GRANT ALL PRIVILEGES ON culturarte.* TO 'culturarte'@'localhost';"
fi

# Aplicar cambios
echo ""
echo -e "${YELLOW}Aplicando cambios...${NC}"
if $MYSQL_CMD -u root -e "FLUSH PRIVILEGES;" 2>/dev/null; then
    echo -e "${GREEN}Cambios aplicados${NC}"
else
    echo "Por favor, ingresa la contraseña de root cuando se solicite:"
    $MYSQL_CMD -u root -p -e "FLUSH PRIVILEGES;"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}  Configuración completada${NC}"
echo "=========================================="
echo ""
echo "El usuario 'culturarte' ahora tiene acceso a la base de datos 'culturarte'"
echo ""
echo "Credenciales:"
echo "  Usuario: culturarte"
echo "  Contraseña: culturarte123"
echo "  Base de datos: culturarte"
echo ""
echo "Presiona Enter para cerrar..."
read -r


