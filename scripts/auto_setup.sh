#!/bin/bash

# Script automatizado para configurar proyecto GitHub
# Lee configuración desde .env y archivo JSON
# Uso: ./auto_setup.sh [config_file]

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración por defecto
DEFAULT_CONFIG="finanzen_config.json"
CONFIG_FILE="${1:-$DEFAULT_CONFIG}"

echo -e "${BLUE}🚀 GitHub Project Auto Setup${NC}"
echo -e "${CYAN}Configuración automatizada desde archivos${NC}"
echo "========================================"

# Verificar que estemos en el directorio correcto
if [ ! -f "setup_github_project.py" ]; then
    echo -e "${RED}❌ Error: Ejecuta este script desde el directorio scripts/${NC}"
    exit 1
fi

# Verificar que existe el archivo de configuración
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: Archivo de configuración '$CONFIG_FILE' no encontrado${NC}"
    echo -e "${YELLOW}💡 Archivos disponibles:${NC}"
    ls -la *.json 2>/dev/null || echo "   No hay archivos JSON en este directorio"
    exit 1
fi

echo -e "${GREEN}📄 Usando configuración: $CONFIG_FILE${NC}"

# Cargar variables de entorno
if [ -f ".env" ]; then
    echo -e "${GREEN}🔧 Cargando variables de entorno desde .env${NC}"
    set -a  # automatically export all variables
    source .env
    set +a  # disable automatic export
else
    echo -e "${YELLOW}⚠️  Archivo .env no encontrado${NC}"
    echo -e "${YELLOW}💡 Copia .env.example a .env y configura tus credenciales${NC}"
    
    if [ -f ".env.example" ]; then
        echo -e "${CYAN}¿Quieres crear .env desde .env.example ahora? (y/N)${NC}"
        read -p "> " CREATE_ENV
        
        if [ "$CREATE_ENV" = "y" ] || [ "$CREATE_ENV" = "Y" ]; then
            cp .env.example .env
            echo -e "${GREEN}✅ Archivo .env creado${NC}"
            echo -e "${YELLOW}📝 Por favor, edita .env con tus credenciales reales y ejecuta el script nuevamente${NC}"
            exit 0
        fi
    fi
    
    echo -e "${RED}❌ No se pueden cargar las credenciales${NC}"
    exit 1
fi

# Verificar variables requeridas
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ Error: GITHUB_TOKEN no está configurado en .env${NC}"
    exit 1
fi

# Extraer información del archivo JSON usando Python
echo -e "${BLUE}📋 Leyendo configuración del proyecto...${NC}"

OWNER=$(python3 -c "
import json
import sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('repository', {}).get('owner', ''))
except:
    sys.exit(1)
")

REPO=$(python3 -c "
import json
import sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('repository', {}).get('name', ''))
except:
    sys.exit(1)
")

PROJECT_TITLE=$(python3 -c "
import json
import sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('project', {}).get('title', ''))
except:
    sys.exit(1)
")

AUTO_ASSIGN=$(python3 -c "
import json
import sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('options', {}).get('auto_assign_issues', True))
except:
    print(True)
")

DRY_RUN_FIRST=$(python3 -c "
import json
import sys
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('options', {}).get('dry_run_first', True))
except:
    print(True)
")

# Usar variables de entorno como fallback si no están en JSON
OWNER="${OWNER:-$GITHUB_OWNER}"
REPO="${REPO:-$GITHUB_REPO}"

# Verificar que tenemos toda la información necesaria
if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo -e "${RED}❌ Error: Información del repositorio incompleta${NC}"
    echo "   Owner: ${OWNER:-'NO CONFIGURADO'}"
    echo "   Repo: ${REPO:-'NO CONFIGURADO'}"
    echo -e "${YELLOW}💡 Verifica la configuración en $CONFIG_FILE o .env${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Configuración cargada:${NC}"
echo "   📁 Repositorio: $OWNER/$REPO"
echo "   📋 Proyecto: $PROJECT_TITLE"
echo "   🔧 Auto-assign issues: $AUTO_ASSIGN"
echo "   🧪 Dry-run primero: $DRY_RUN_FIRST"

# Verificar e instalar dependencias
if ! python3 -c "import requests" 2>/dev/null; then
    echo -e "\n${YELLOW}📦 Instalando dependencias...${NC}"
    pip3 install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error instalando dependencias${NC}"
        exit 1
    fi
fi

echo -e "\n${BLUE}🚀 Iniciando configuración automática...${NC}"
echo -e "${CYAN}⏱️  Esto puede tomar unos momentos...${NC}"

# Ejecutar script principal
echo -e "\n${BLUE}📋 Creando proyecto y milestones...${NC}"
python3 setup_github_project.py \
    --owner "$OWNER" \
    --repo "$REPO" \
    --token "$GITHUB_TOKEN" \
    --config "$CONFIG_FILE"

SETUP_RESULT=$?

if [ $SETUP_RESULT -eq 0 ]; then
    echo -e "\n${GREEN}✅ Proyecto y milestones verificados exitosamente!${NC}"
    
    # Auto-asignar issues si está habilitado
    if [ "$AUTO_ASSIGN" = "True" ] || [ "$AUTO_ASSIGN" = "true" ]; then
        echo -e "\n${BLUE}🎯 Auto-asignando issues a milestones...${NC}"
        
        # Dry-run primero si está habilitado
        if [ "$DRY_RUN_FIRST" = "True" ] || [ "$DRY_RUN_FIRST" = "true" ]; then
            echo -e "${YELLOW}🧪 Ejecutando dry-run primero...${NC}"
            python3 assign_issues_to_milestones.py \
                --owner "$OWNER" \
                --repo "$REPO" \
                --token "$GITHUB_TOKEN" \
                --dry-run
            
            if [ $? -eq 0 ]; then
                echo -e "\n${CYAN}¿Proceder con las asignaciones reales? (Y/n)${NC}"
                read -p "> " CONFIRM
                CONFIRM=${CONFIRM:-Y}  # Default a Y si está vacío
                
                if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
                    echo -e "${BLUE}✨ Ejecutando asignaciones reales...${NC}"
                    python3 assign_issues_to_milestones.py \
                        --owner "$OWNER" \
                        --repo "$REPO" \
                        --token "$GITHUB_TOKEN"
                else
                    echo -e "${YELLOW}⏭️  Asignaciones omitidas por el usuario${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️  Dry-run falló, omitiendo asignaciones reales${NC}"
            fi
        else
            # Ejecutar directamente sin dry-run
            python3 assign_issues_to_milestones.py \
                --owner "$OWNER" \
                --repo "$REPO" \
                --token "$GITHUB_TOKEN"
        fi
    else
        echo -e "\n${YELLOW}⏭️  Auto-asignación de issues deshabilitada en configuración${NC}"
    fi
    
    echo -e "\n${GREEN}🎉 ¡Configuración completada exitosamente!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}🌐 Repositorio: https://github.com/$OWNER/$REPO${NC}"
    echo -e "${BLUE}📋 Issues: https://github.com/$OWNER/$REPO/issues${NC}"
    echo -e "${BLUE}🎯 Milestones: https://github.com/$OWNER/$REPO/milestones${NC}"
    echo -e "${BLUE}📊 Projects: https://github.com/$OWNER?tab=projects${NC}"
    
else
    echo -e "\n${RED}❌ Error en la configuración del proyecto${NC}"
    echo -e "${YELLOW}💡 Verifica:${NC}"
    echo "   - Que el token tenga los permisos correctos"
    echo "   - Que el repositorio exista y tengas acceso"
    echo "   - Que la configuración JSON sea válida"
    exit 1
fi
