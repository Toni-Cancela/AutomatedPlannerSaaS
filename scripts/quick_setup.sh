#!/bin/bash

# Script de conveniencia para configurar proyecto GitHub
# Uso: ./quick_setup.sh

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 GitHub Project Setup - FinanZen${NC}"
echo "=================================="

# Verificar que estemos en el directorio correcto
if [ ! -f "setup_github_project.py" ]; then
    echo -e "${RED}❌ Error: Ejecuta este script desde el directorio scripts/${NC}"
    exit 1
fi

# Verificar que requirements esté instalado
if ! python3 -c "import requests" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Instalando dependencias...${NC}"
    pip3 install -r requirements.txt
fi

# Solicitar información necesaria
echo -e "\n${YELLOW}📝 Configuración:${NC}"

read -p "GitHub Username/Owner (ej: Toni-Cancela): " OWNER
read -p "Nombre del repositorio (ej: FinanZen): " REPO

echo -e "\n${YELLOW}🔑 Necesitas un GitHub Personal Access Token${NC}"
echo "Si no tienes uno, créalo en: https://github.com/settings/tokens"
echo "Permisos necesarios: repo, project, write:org"
echo

read -s -p "GitHub Token: " TOKEN
echo

# Verificar que se hayan proporcionado todos los valores
if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$TOKEN" ]; then
    echo -e "\n${RED}❌ Error: Todos los campos son obligatorios${NC}"
    exit 1
fi

echo -e "\n${BLUE}📋 Creando proyecto y milestones...${NC}"

# Ejecutar script principal
python3 setup_github_project.py \
    --owner "$OWNER" \
    --repo "$REPO" \
    --token "$TOKEN" \
    --config finanzen_config.json

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ Proyecto creado exitosamente!${NC}"
    
    echo -e "\n${YELLOW}🎯 ¿Quieres asignar issues existentes a milestones? (y/N)${NC}"
    read -p "> " ASSIGN_ISSUES
    
    if [ "$ASSIGN_ISSUES" = "y" ] || [ "$ASSIGN_ISSUES" = "Y" ]; then
        echo -e "\n${BLUE}🔄 Asignando issues a milestones...${NC}"
        
        # Primero hacer dry-run
        echo -e "${YELLOW}Ejecutando dry-run primero...${NC}"
        python3 assign_issues_to_milestones.py \
            --owner "$OWNER" \
            --repo "$REPO" \
            --token "$TOKEN" \
            --dry-run
        
        echo -e "\n${YELLOW}¿Proceder con las asignaciones? (y/N)${NC}"
        read -p "> " CONFIRM
        
        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
            python3 assign_issues_to_milestones.py \
                --owner "$OWNER" \
                --repo "$REPO" \
                --token "$TOKEN"
        else
            echo -e "${YELLOW}⏭️  Asignación de issues omitida${NC}"
        fi
    fi
    
    echo -e "\n${GREEN}🎉 ¡Configuración completada!${NC}"
    echo -e "${BLUE}🌐 Repositorio: https://github.com/$OWNER/$REPO${NC}"
    echo -e "${BLUE}📋 Issues: https://github.com/$OWNER/$REPO/issues${NC}"
    echo -e "${BLUE}🎯 Milestones: https://github.com/$OWNER/$REPO/milestones${NC}"
    
else
    echo -e "\n${RED}❌ Error en la configuración${NC}"
    exit 1
fi
