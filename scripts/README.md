# 🛠️ Scripts de Automatización para GitHub Projects

Este directorio contiene scripts de Python para automatizar la creación y gestión de GitHub Projects y Milestones.

## 📁 Archivos incluidos

- `setup_github_project.py` - Crea GitHub Projects y Milestones
- `assign_issues_to_milestones.py` - Asigna issues existentes a milestones
- `finanzen_config.json` - Configuración específica para FinanZen
- `requirements.txt` - Dependencias de Python

## 🚀 Configuración inicial

### 1. Instalar dependencias

```bash
cd scripts
pip install -r requirements.txt
```

### 2. Crear GitHub Personal Access Token

1. Ve a GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Genera un nuevo token con estos permisos:
   - `repo` (acceso completo a repositorios)
   - `project` (acceso a GitHub Projects)
   - `write:org` (si trabajas con organizaciones)

⚠️ **Importante**: Guarda el token de forma segura, no lo compartas ni lo subas al repositorio.

## 📋 Uso de los scripts

### 🚀 **Opción 1: Script automatizado (Recomendado)**

```bash
# Configuración inicial (solo la primera vez)
cp .env.example .env
# Edita .env con tus credenciales

# Ejecutar configuración automática
./auto_setup.sh
```

### 🛠️ **Opción 2: Script manual individual**

```bash
python setup_github_project.py \
  --owner Toni-Cancela \
  --repo FinanZen \
  --token TU_GITHUB_TOKEN \
  --config finanzen_config.json
```

### **Configuración de credenciales**

1. **Copia el archivo de ejemplo:**
   ```bash
   cp .env.example .env
   ```

2. **Edita .env con tus datos:**
   ```bash
   GITHUB_TOKEN=tu_token_real_aqui
   GITHUB_OWNER=Toni-Cancela
   GITHUB_REPO=FinanZen
   ```

### **Lo que hace el script automatizado:**
- ✅ Lee configuración desde archivos JSON y .env
- ✅ Crea un nuevo GitHub Project (V2)
- ✅ Vincula el repositorio al proyecto
- ✅ Crea todos los milestones definidos en la configuración
- ✅ Auto-asigna issues a milestones (opcional)
- ✅ Ejecuta dry-run antes de cambios reales

### Script 2: Asignar issues a milestones

```bash
python assign_issues_to_milestones.py \
  --owner Toni-Cancela \
  --repo FinanZen \
  --token TU_GITHUB_TOKEN
```

**Parámetros:**
- `--owner`: Propietario del repositorio
- `--repo`: Nombre del repositorio  
- `--token`: Tu GitHub Personal Access Token
- `--dry-run`: (Opcional) Modo de prueba sin hacer cambios reales

**Lo que hace:**
- 🔍 Analiza todas las issues del repositorio
- 🏷️ Identifica issues con labels de milestone (`milestone-1-setup`, etc.)
- 📋 Asigna automáticamente cada issue al milestone correspondiente

## 🎯 Mapeo de labels a milestones

El script usa este mapeo automático:

| Label | Milestone |
|-------|-----------|
| `milestone-1-setup` | 🏗️ Setup/Inicialización |
| `milestone-2-mvp` | 🚀 MVP Implementation |
| `milestone-3-optimization` | ⚡ Optimización Financiera |
| `milestone-4-charts` | 📊 Gráficas e Info Visual |

## ⚙️ Personalización

### **Estructura del archivo de configuración JSON**

```json
{
  "repository": {
    "owner": "tu-username",
    "name": "tu-repositorio"
  },
  "project": {
    "title": "Mi Proyecto",
    "description": "Descripción del proyecto"
  },
  "milestones": [
    {
      "title": "Mi Milestone",
      "description": "Descripción detallada",
      "due_date": "2025-12-31T23:59:59Z"
    }
  ],
  "options": {
    "auto_assign_issues": true,
    "dry_run_first": true
  }
}
```

### **Variables de entorno disponibles**

```bash
# Requerido
GITHUB_TOKEN=tu_token_aqui

# Opcional (se puede definir en JSON también)
GITHUB_OWNER=tu-username
GITHUB_REPO=tu-repositorio
PROJECT_CONFIG_FILE=archivo_config.json
```

### **Para otros proyectos**

```bash
# Crear nueva configuración
cp finanzen_config.json mi_proyecto_config.json
# Editar mi_proyecto_config.json

# Ejecutar con configuración personalizada
./auto_setup.sh mi_proyecto_config.json
```

## 🔒 Seguridad

**El archivo .env contiene credenciales sensibles y NO debe subirse al repositorio.**

### **Configuración segura:**

1. **Usa .env para credenciales:**
   ```bash
   # ✅ Correcto - usar archivo .env
   GITHUB_TOKEN="tu_token_aqui"
   
   # ❌ Incorrecto - hardcodear en scripts
   TOKEN="ghp_xxxxxxxxxxxx"
   ```

2. **Verifica .gitignore:**
   ```bash
   # Asegúrate de que .env esté excluido
   echo ".env" >> .gitignore
   ```

3. **Variables de entorno del sistema (alternativa):**
   ```bash
   export GITHUB_TOKEN="tu_token_aqui"
   ./auto_setup.sh
   ```

## 🐛 Troubleshooting

### Error de permisos
- Verifica que tu token tenga los permisos correctos
- Asegúrate de tener acceso de escritura al repositorio

### Error "repository not found"
- Verifica que el owner y repo sean correctos
- El repositorio debe existir antes de ejecutar los scripts

### Error en GraphQL (Projects)
- Los GitHub Projects V2 requieren permisos específicos
- Asegúrate de que el token tenga permisos de `project`

## 📚 Recursos adicionales

- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [GitHub GraphQL API Documentation](https://docs.github.com/en/graphql)
- [GitHub Projects V2 Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)

---

💡 **Tip**: Usa `--dry-run` primero para ver qué cambios se harían antes de aplicarlos realmente.
