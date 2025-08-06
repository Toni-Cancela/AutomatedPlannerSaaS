#!/bin/bash

# Script para probar la lógica del workflow move-issue-to-done.yml
# Uso: ./test-workflow.sh <numero-issue>

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ $# -ne 1 ]; then
    echo -e "${RED}Error:${NC} Se requiere el número de issue"
    echo -e "${BLUE}Uso:${NC} ./test-workflow.sh <numero-issue>"
    exit 1
fi

ISSUE_NUMBER=$1
OWNER="Toni-Cancela"
REPO="AutomatedPlannerSaaS"

echo -e "${BLUE}🔍 Probando lógica del workflow para issue #${ISSUE_NUMBER}...${NC}"
echo ""

# 1. Verificar si la issue existe
echo -e "${YELLOW}1. Verificando si la issue existe...${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$OWNER/$REPO/issues/$ISSUE_NUMBER")

if [ "$response" != "200" ]; then
    echo -e "${RED}❌ Issue #$ISSUE_NUMBER no existe (código: $response)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Issue #$ISSUE_NUMBER existe${NC}"

# 2. Obtener información del proyecto
echo -e "${YELLOW}2. Obteniendo información del proyecto...${NC}"
project_data=$(gh api graphql -f query='
  query($owner: String!) {
    user(login: $owner) {
      projectsV2(first: 20) {
        nodes {
          id
          title
          number
        }
      }
    }
  }
' -f owner="$OWNER")

project_id=$(echo "$project_data" | jq -r '.data.user.projectsV2.nodes[] | select(.title | test("AutomatedPlannerSaaS"; "i")) | .id')

if [ -z "$project_id" ]; then
    echo -e "${RED}❌ No se encontró proyecto 'AutomatedPlannerSaaS'${NC}"
    echo "Proyectos disponibles:"
    echo "$project_data" | jq -r '.data.user.projectsV2.nodes[] | .title'
    exit 1
fi
echo -e "${GREEN}✅ Proyecto encontrado: $project_id${NC}"

# 3. Obtener el item de la issue en el proyecto
echo -e "${YELLOW}3. Obteniendo item de la issue en el proyecto...${NC}"
issue_data=$(gh api graphql -f query='
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
' -f owner="$OWNER" -f repo="$REPO" -F issueNumber="$ISSUE_NUMBER")

project_item_id=$(echo "$issue_data" | jq -r --arg projectId "$project_id" '.data.repository.issue.projectItems.nodes[] | select(.project.id == $projectId) | .id')

if [ -z "$project_item_id" ]; then
    echo -e "${RED}❌ Issue #$ISSUE_NUMBER no está asociada al proyecto${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Item encontrado: $project_item_id${NC}"

# 4. Verificar el estado actual
echo -e "${YELLOW}4. Verificando estado actual de la issue...${NC}"
current_item_data=$(gh api graphql -f query='
  query($projectId: ID!, $itemId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 {
        item(id: $itemId) {
          fieldValues(first: 10) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                field {
                  ... on ProjectV2SingleSelectField {
                    name
                  }
                }
                name
              }
            }
          }
        }
      }
    }
  }
' -f projectId="$project_id" -f itemId="$project_item_id")

current_status=$(echo "$current_item_data" | jq -r '.data.node.item.fieldValues.nodes[] | select(.field.name | test("Status|Estado"; "i")) | .name // "unknown"')

echo -e "${BLUE}Estado actual de la issue: '$current_status'${NC}"

if [ "$current_status" = "In Review" ]; then
    echo -e "${GREEN}✅ La issue está en 'In Review' - se movería a 'Done'${NC}"
else
    echo -e "${YELLOW}⚠️  La issue NO está en 'In Review' - no se movería automáticamente${NC}"
    echo -e "${BLUE}Estados válidos para mover a Done: 'In Review'${NC}"
fi

echo ""
echo -e "${BLUE}🎉 Prueba completada${NC}"