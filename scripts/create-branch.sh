#!/bin/bash

# Script para crear una nueva rama y asociarla a una issue
# Uso: ./create-branch.sh <nombre-rama> <numero-issue>

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Uso:${NC} ./create-branch.sh <nombre-rama> <numero-issue>"
    echo -e "${BLUE}Ejemplo:${NC} ./create-branch.sh feature/authentication-user 123"
    echo ""
    echo -e "${YELLOW}Descripción:${NC}"
    echo "  - Crea una nueva rama con el formato: <nombre-rama>-<numero-issue>"
    echo "  - Pushea la rama al repositorio remoto"
    echo "  - Asocia la rama a la issue especificada"
    echo "  - Mueve la issue al estado 'In Progress'"
    echo ""
    echo -e "${YELLOW}Requisitos:${NC}"
    echo "  - GitHub CLI (gh) instalado y autenticado"
    echo "  - Estar en un repositorio de Git"
    echo "  - Tener permisos para crear ramas y modificar issues"
}

# Verificar parámetros
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ $# -ne 2 ]; then
    echo -e "${RED}Error:${NC} Se requieren exactamente 2 parámetros"
    show_help
    exit 1
fi

BRANCH_NAME=$1
ISSUE_NUMBER=$2
FULL_BRANCH_NAME="${BRANCH_NAME}-${ISSUE_NUMBER}"

# Verificar que estamos en un repositorio git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error:${NC} No estás en un repositorio de Git"
    exit 1
fi

# Verificar que GitHub CLI está instalado
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error:${NC} GitHub CLI (gh) no está instalado"
    echo "Instálalo desde: https://cli.github.com/"
    exit 1
fi

# Verificar que GitHub CLI está autenticado
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error:${NC} GitHub CLI no está autenticado"
    echo "Ejecuta: gh auth login"
    exit 1
fi

echo -e "${BLUE}🚀 Iniciando creación de rama...${NC}"

# Obtener información del repositorio
REPO_INFO=$(gh repo view --json owner,name)
OWNER=$(echo $REPO_INFO | jq -r '.owner.login')
REPO=$(echo $REPO_INFO | jq -r '.name')

echo -e "${YELLOW}📋 Información:${NC}"
echo "  Repositorio: $OWNER/$REPO"
echo "  Rama: $FULL_BRANCH_NAME"
echo "  Issue: #$ISSUE_NUMBER"

# Verificar que la issue existe
echo -e "${BLUE}🔍 Verificando issue #$ISSUE_NUMBER...${NC}"
if ! gh issue view $ISSUE_NUMBER &> /dev/null; then
    echo -e "${RED}Error:${NC} La issue #$ISSUE_NUMBER no existe"
    exit 1
fi

# Asegurarse de estar en develop
echo -e "${BLUE}🔄 Cambiando a rama develop...${NC}"
git checkout develop

# Actualizar develop
echo -e "${BLUE}📥 Actualizando rama develop...${NC}"
git pull origin develop

# Crear la nueva rama
echo -e "${BLUE}🌿 Creando rama $FULL_BRANCH_NAME...${NC}"
git checkout -b $FULL_BRANCH_NAME

# Pushear la rama
echo -e "${BLUE}📤 Pusheando rama al repositorio remoto...${NC}"
git push -u origin $FULL_BRANCH_NAME

# Obtener información de la issue para el proyecto
echo -e "${BLUE}📊 Obteniendo información del proyecto...${NC}"

# Buscar el proyecto y obtener su ID
PROJECT_INFO=$(gh api graphql -f query='
  query($owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      projectsV2(first: 10) {
        nodes {
          id
          title
          number
        }
      }
    }
  }
' -f owner=$OWNER -f repo=$REPO)

PROJECT_ID=$(echo $PROJECT_INFO | jq -r '.data.repository.projectsV2.nodes[0].id // empty')

if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}⚠️  No se encontró un proyecto asociado al repositorio${NC}"
    echo -e "${GREEN}✅ Rama creada exitosamente: $FULL_BRANCH_NAME${NC}"
    exit 0
fi

# Obtener el ID de la issue en el proyecto
ISSUE_PROJECT_INFO=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $issueNumber: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $issueNumber) {
        id
        projectItems(first: 10) {
          nodes {
            id
            project {
              id
            }
          }
        }
      }
    }
  }
' -f owner=$OWNER -f repo=$REPO -F issueNumber=$ISSUE_NUMBER)

ISSUE_ID=$(echo $ISSUE_PROJECT_INFO | jq -r '.data.repository.issue.id')
PROJECT_ITEM_ID=""

# Buscar si la issue ya está en el proyecto
for item in $(echo $ISSUE_PROJECT_INFO | jq -r '.data.repository.issue.projectItems.nodes[] | select(.project.id == "'$PROJECT_ID'") | .id'); do
    PROJECT_ITEM_ID=$item
    break
done

# Si la issue no está en el proyecto, añadirla
if [ -z "$PROJECT_ITEM_ID" ]; then
    echo -e "${BLUE}📌 Añadiendo issue al proyecto...${NC}"
    ADD_RESULT=$(gh api graphql -f query='
      mutation($projectId: ID!, $contentId: ID!) {
        addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
          item {
            id
          }
        }
      }
    ' -f projectId=$PROJECT_ID -f contentId=$ISSUE_ID)
    
    PROJECT_ITEM_ID=$(echo $ADD_RESULT | jq -r '.data.addProjectV2ItemById.item.id')
fi

# Obtener los campos del proyecto para encontrar el campo de estado
echo -e "${BLUE}🔍 Buscando campo de estado en el proyecto...${NC}"
PROJECT_FIELDS=$(gh api graphql -f query='
  query($projectId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 {
        fields(first: 20) {
          nodes {
            ... on ProjectV2SingleSelectField {
              id
              name
              options {
                id
                name
              }
            }
          }
        }
      }
    }
  }
' -f projectId=$PROJECT_ID)

# Buscar el campo de estado (normalmente se llama "Status")
STATUS_FIELD_ID=""
IN_PROGRESS_OPTION_ID=""

# Buscar el campo de estado
STATUS_FIELD_ID=$(echo $PROJECT_FIELDS | jq -r '.data.node.fields.nodes[] | select(.name != null and (.name | test("Status|Estado"; "i"))) | .id' | head -1)

if [ ! -z "$STATUS_FIELD_ID" ]; then
    # Buscar la opción "In Progress"
    IN_PROGRESS_OPTION_ID=$(echo $PROJECT_FIELDS | jq -r --arg fieldId "$STATUS_FIELD_ID" '.data.node.fields.nodes[] | select(.id == $fieldId) | .options[]? | select(.name != null and (.name | test("In Progress|En Progreso|In progress"; "i"))) | .id' | head -1)
fi

# Actualizar el estado de la issue a "In Progress"
if [ ! -z "$STATUS_FIELD_ID" ] && [ ! -z "$IN_PROGRESS_OPTION_ID" ] && [ ! -z "$PROJECT_ITEM_ID" ]; then
    echo -e "${BLUE}📝 Moviendo issue a 'In Progress'...${NC}"
    gh api graphql -f query='
      mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
        updateProjectV2ItemFieldValue(input: {
          projectId: $projectId
          itemId: $itemId
          fieldId: $fieldId
          value: {singleSelectOptionId: $optionId}
        }) {
          projectV2Item {
            id
          }
        }
      }
    ' -f projectId=$PROJECT_ID -f itemId=$PROJECT_ITEM_ID -f fieldId=$STATUS_FIELD_ID -f optionId=$IN_PROGRESS_OPTION_ID
    
    echo -e "${GREEN}✅ Issue #$ISSUE_NUMBER movida a 'In Progress'${NC}"
else
    echo -e "${YELLOW}⚠️  No se pudo mover la issue automáticamente. Muévela manualmente a 'In Progress'${NC}"
fi

echo ""
echo -e "${GREEN}🎉 ¡Proceso completado exitosamente!${NC}"
echo -e "${GREEN}✅ Rama creada: $FULL_BRANCH_NAME${NC}"
echo -e "${GREEN}✅ Rama pusheada al repositorio remoto${NC}"
echo -e "${GREEN}✅ Issue #$ISSUE_NUMBER asociada a la rama${NC}"
echo ""
echo -e "${BLUE}📝 Próximos pasos:${NC}"
echo "  1. Realiza tus cambios en la rama $FULL_BRANCH_NAME"
echo "  2. Haz commits siguiendo las convenciones del proyecto"
echo "  3. Cuando termines, ejecuta: ./create-pr.sh $BRANCH_NAME $ISSUE_NUMBER"
