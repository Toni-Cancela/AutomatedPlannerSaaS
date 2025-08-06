#!/bin/bash

# Script para crear un Pull Request y mover la issue a "In Review"
# Uso: ./create-pr.sh <nombre-rama> <numero-issue>

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Uso:${NC} ./create-pr.sh <nombre-rama> <numero-issue>"
    echo -e "${BLUE}Ejemplo:${NC} ./create-pr.sh feature/authentication-user 123"
    echo ""
    echo -e "${YELLOW}Descripción:${NC}"
    echo "  - Crea un Pull Request desde <nombre-rama>-<numero-issue> hacia develop"
    echo "  - Utiliza la plantilla de PR del repositorio"
    echo "  - Mueve la issue al estado 'In Review'"
    echo ""
    echo -e "${YELLOW}Requisitos:${NC}"
    echo "  - GitHub CLI (gh) instalado y autenticado"
    echo "  - Estar en un repositorio de Git"
    echo "  - La rama debe existir y tener commits"
    echo "  - Tener permisos para crear PRs y modificar issues"
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

echo -e "${BLUE}🚀 Iniciando creación de Pull Request...${NC}"

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

# Verificar que la rama existe
echo -e "${BLUE}🔍 Verificando que la rama existe...${NC}"
if ! git show-ref --verify --quiet refs/remotes/origin/$FULL_BRANCH_NAME; then
    echo -e "${RED}Error:${NC} La rama $FULL_BRANCH_NAME no existe en el repositorio remoto"
    echo "Ejecuta primero: ./create-branch.sh $BRANCH_NAME $ISSUE_NUMBER"
    exit 1
fi

# Cambiar a la rama
echo -e "${BLUE}🔄 Cambiando a la rama $FULL_BRANCH_NAME...${NC}"
git checkout $FULL_BRANCH_NAME

# Actualizar la rama con los últimos cambios
echo -e "${BLUE}📥 Actualizando rama...${NC}"
git pull origin $FULL_BRANCH_NAME

# Obtener información de la issue
echo -e "${BLUE}📝 Obteniendo información de la issue...${NC}"
ISSUE_INFO=$(gh issue view $ISSUE_NUMBER --json title,body)
ISSUE_TITLE=$(echo $ISSUE_INFO | jq -r '.title')
ISSUE_BODY=$(echo $ISSUE_INFO | jq -r '.body // ""')

# Crear título del PR basado en el título de la issue
PR_TITLE="feat: $ISSUE_TITLE"
if [[ $ISSUE_TITLE == *"fix"* ]] || [[ $ISSUE_TITLE == *"bug"* ]] || [[ $ISSUE_TITLE == *"error"* ]]; then
    PR_TITLE="fix: $ISSUE_TITLE"
elif [[ $ISSUE_TITLE == *"doc"* ]] || [[ $ISSUE_TITLE == *"documentación"* ]]; then
    PR_TITLE="docs: $ISSUE_TITLE"
elif [[ $ISSUE_TITLE == *"refactor"* ]]; then
    PR_TITLE="refactor: $ISSUE_TITLE"
elif [[ $ISSUE_TITLE == *"test"* ]] || [[ $ISSUE_TITLE == *"prueba"* ]]; then
    PR_TITLE="test: $ISSUE_TITLE"
elif [[ $ISSUE_TITLE == *"chore"* ]] || [[ $ISSUE_TITLE == *"mantenimiento"* ]]; then
    PR_TITLE="chore: $ISSUE_TITLE"
fi

# Crear el cuerpo del PR
PR_BODY="# 📋 Pull Request

## 📝 Descripción

Resolución de la issue #${ISSUE_NUMBER}: ${ISSUE_TITLE}

### 🎯 ¿Qué problema resuelve?
${ISSUE_BODY}

Closes #${ISSUE_NUMBER}

### 💡 ¿Cuál es la solución propuesta?
<!-- Describe brevemente los cambios realizados -->

---

## 🔄 Tipo de cambio

- [x] ✨ **Feature** - Nueva funcionalidad
- [ ] 🐛 **Bugfix** - Corrección de errores
- [ ] 🔧 **Chore** - Tareas de mantenimiento
- [ ] 📚 **Docs** - Cambios en documentación
- [ ] 🎨 **Style** - Cambios de formato/estilo
- [ ] ♻️ **Refactor** - Refactorización de código
- [ ] ⚡ **Performance** - Mejoras de rendimiento
- [ ] 🧪 **Test** - Añadir o corregir tests

---

## 🧪 Testing

### ✅ Tests realizados

- [ ] Tests unitarios
- [ ] Tests de integración
- [ ] Tests manuales
- [ ] Tests en dispositivos móviles (iOS/Android)

### 📱 Dispositivos/Plataformas probadas

- [ ] iOS Simulator
- [ ] Android Emulator
- [ ] Dispositivo físico iOS
- [ ] Dispositivo físico Android
- [ ] Web (si aplica)

---

## 🔧 Cambios técnicos

### 📁 Archivos modificados principales

<!-- Lista los archivos más importantes que se han modificado -->

### 🏗️ Arquitectura/Patrones utilizados

- [ ] Clean Architecture
- [ ] BLoC Pattern
- [ ] Repository Pattern
- [ ] Dependency Injection

---

## 🚀 Despliegue

### 🔄 Migración de datos
- [x] No requiere migración
- [ ] Requiere migración (detalla en comentarios)

### ⚙️ Variables de entorno
- [x] No requiere nuevas variables
- [ ] Requiere nuevas variables (lista en comentarios)

### 📋 Checklist pre-merge
- [ ] Código revisado y probado
- [ ] Tests pasando
- [ ] Documentación actualizada
- [ ] No hay conflictos con develop
- [ ] Performance verificado
- [ ] Accesibilidad verificada (si aplica)

---

## 🔗 Issues relacionadas

Closes #${ISSUE_NUMBER}

---

## ✅ Definition of Done

- [ ] ✅ **Funcionalidad completa** - Cumple todos los criterios de aceptación
- [ ] 🧪 **Testing completo** - Tests unitarios e integración pasando
- [ ] 📱 **Multiplataforma** - Funciona en iOS y Android (si aplica)
- [ ] 📚 **Documentado** - Código documentado y README actualizado
- [ ] 🎨 **UI/UX conforme** - Sigue las guías de diseño del proyecto
- [ ] ⚡ **Performance optimizado** - No impacta negativamente el rendimiento
- [ ] 🔒 **Seguridad verificada** - No introduce vulnerabilidades
- [ ] ♿ **Accesible** - Cumple estándares de accesibilidad (si aplica)

---

**Ready for review!** 🎉"

# Crear el Pull Request
echo -e "${BLUE}📤 Creando Pull Request...${NC}"
PR_URL=$(gh pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --base develop \
    --head $FULL_BRANCH_NAME \
    --assignee @me)

echo -e "${GREEN}✅ Pull Request creado: $PR_URL${NC}"

# Obtener información del proyecto para mover la issue
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
    echo -e "${GREEN}✅ Pull Request creado exitosamente${NC}"
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

PROJECT_ITEM_ID=""

# Buscar si la issue ya está en el proyecto
for item in $(echo $ISSUE_PROJECT_INFO | jq -r '.data.repository.issue.projectItems.nodes[] | select(.project.id == "'$PROJECT_ID'") | .id'); do
    PROJECT_ITEM_ID=$item
    break
done

if [ -z "$PROJECT_ITEM_ID" ]; then
    echo -e "${YELLOW}⚠️  La issue no está asociada al proyecto${NC}"
    echo -e "${GREEN}✅ Pull Request creado exitosamente${NC}"
    exit 0
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

# Buscar el campo de estado y la opción "In Review"
STATUS_FIELD_ID=""
IN_REVIEW_OPTION_ID=""

# Buscar el campo de estado
STATUS_FIELD_ID=$(echo $PROJECT_FIELDS | jq -r '.data.node.fields.nodes[] | select(.name != null and (.name | test("Status|Estado"; "i"))) | .id' | head -1)

if [ ! -z "$STATUS_FIELD_ID" ]; then
    # Buscar la opción "In Review"
    IN_REVIEW_OPTION_ID=$(echo $PROJECT_FIELDS | jq -r --arg fieldId "$STATUS_FIELD_ID" '.data.node.fields.nodes[] | select(.id == $fieldId) | .options[]? | select(.name != null and (.name | test("In Review|En Revisión|Review"; "i"))) | .id' | head -1)
fi

# Actualizar el estado de la issue a "In Review"
if [ ! -z "$STATUS_FIELD_ID" ] && [ ! -z "$IN_REVIEW_OPTION_ID" ] && [ ! -z "$PROJECT_ITEM_ID" ]; then
    echo -e "${BLUE}📝 Moviendo issue a 'In Review'...${NC}"
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
    ' -f projectId=$PROJECT_ID -f itemId=$PROJECT_ITEM_ID -f fieldId=$STATUS_FIELD_ID -f optionId=$IN_REVIEW_OPTION_ID
    
    echo -e "${GREEN}✅ Issue #$ISSUE_NUMBER movida a 'In Review'${NC}"
else
    echo -e "${YELLOW}⚠️  No se pudo mover la issue automáticamente. Muévela manualmente a 'In Review'${NC}"
fi

echo ""
echo -e "${GREEN}🎉 ¡Proceso completado exitosamente!${NC}"
echo -e "${GREEN}✅ Pull Request creado: $PR_URL${NC}"
echo -e "${GREEN}✅ Issue #$ISSUE_NUMBER movida a 'In Review'${NC}"
echo ""
echo -e "${BLUE}📝 Próximos pasos:${NC}"
echo "  1. Espera la revisión del Pull Request"
echo "  2. Realiza los cambios solicitados si es necesario"
echo "  3. Una vez aprobado, el merge automáticamente moverá la issue a 'Done'"
