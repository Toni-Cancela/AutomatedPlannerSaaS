#!/usr/bin/env python3
"""
Script para automatizar la creación de GitHub Projects y Milestones
Uso: python setup_github_project.py --owner OWNER --repo REPO --token GITHUB_TOKEN
"""

import argparse
import json
import requests
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional

class GitHubProjectManager:
    def __init__(self, token: str, owner: str, repo: str):
        self.token = token
        self.owner = owner
        self.repo = repo
        self.headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
        }
        self.graphql_headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        self.base_url = 'https://api.github.com'
        self.graphql_url = 'https://api.github.com/graphql'

    def create_milestone(self, title: str, description: str, due_date: Optional[str] = None) -> Dict:
        """Crear un milestone en el repositorio"""
        # Primero verificar si ya existe
        existing_milestones = self.get_existing_milestones()
        if title in existing_milestones:
            print(f"ℹ️  Milestone '{title}' ya existe (#{existing_milestones[title]})")
            return {'number': existing_milestones[title], 'title': title}
        
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/milestones"
        
        data = {
            'title': title,
            'description': description,
            'state': 'open'
        }
        
        if due_date:
            data['due_on'] = due_date
        
        response = requests.post(url, headers=self.headers, json=data)
        
        if response.status_code == 201:
            milestone = response.json()
            print(f"✅ Milestone creado: {title} (#{milestone['number']})")
            return milestone
        else:
            print(f"❌ Error creando milestone {title}: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return {}

    def get_existing_milestones(self) -> Dict[str, int]:
        """Obtener milestones existentes en el repositorio"""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/milestones"
        response = requests.get(url, headers=self.headers)
        
        if response.status_code == 200:
            milestones = response.json()
            return {milestone['title']: milestone['number'] for milestone in milestones}
        return {}

    def get_user_id(self) -> Optional[str]:
        """Obtener el ID del usuario autenticado"""
        query = """
        query {
            viewer {
                id
                login
            }
        }
        """
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={'query': query}
        )
        
        if response.status_code == 200:
            data = response.json()
            return data['data']['viewer']['id']
        return None

    def create_repository_if_not_exists(self) -> bool:
        """Crear repositorio si no existe"""
        # Primero verificar si ya existe
        repo_url = f"{self.base_url}/repos/{self.owner}/{self.repo}"
        response = requests.get(repo_url, headers=self.headers)
        
        if response.status_code == 200:
            print(f"ℹ️  Repositorio {self.owner}/{self.repo} ya existe")
            return True
        elif response.status_code == 404:
            # Repositorio no existe, crear uno nuevo
            print(f"📁 Creando repositorio {self.owner}/{self.repo}...")
            
            create_url = f"{self.base_url}/user/repos"
            data = {
                'name': self.repo,
                'description': f'Repositorio para el proyecto {self.repo}',
                'private': False,
                'auto_init': True
            }
            
            response = requests.post(create_url, headers=self.headers, json=data)
            
            if response.status_code == 201:
                print(f"✅ Repositorio creado exitosamente")
                return True
            else:
                print(f"❌ Error creando repositorio: {response.status_code}")
                print(f"   Respuesta: {response.text}")
                return False
        else:
            print(f"❌ Error verificando repositorio: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False

    def get_repository_id(self) -> Optional[str]:
        """Obtener el ID del repositorio"""
        query = """
        query($owner: String!, $name: String!) {
            repository(owner: $owner, name: $name) {
                id
                owner {
                    id
                }
            }
        }
        """
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={
                'query': query,
                'variables': {'owner': self.owner, 'name': self.repo}
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'errors' not in data:
                return data['data']['repository']['id']
        return None

    def get_existing_projects(self) -> Dict[str, str]:
        """Obtener proyectos existentes del repositorio"""
        query = """
        query($owner: String!, $name: String!) {
            repository(owner: $owner, name: $name) {
                projectsV2(first: 20) {
                    nodes {
                        id
                        title
                        url
                    }
                }
            }
        }
        """
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={
                'query': query,
                'variables': {'owner': self.owner, 'name': self.repo}
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'errors' not in data and data['data']['repository']:
                projects = data['data']['repository']['projectsV2']['nodes']
                return {project['title']: project['id'] for project in projects}
        return {}

    def create_project_v2(self, title: str, description: str) -> Optional[str]:
        """Crear un proyecto usando GitHub Projects V2 (GraphQL) asociado al repositorio"""
        # Verificar si ya existe un proyecto con el mismo título
        existing_projects = self.get_existing_projects()
        if title in existing_projects:
            print(f"ℹ️  Proyecto '{title}' ya existe")
            project_id = existing_projects[title]
            # Intentar vincular el repositorio y añadir issues aunque ya exista
            self.link_repository_to_project(project_id)
            return project_id
        
        repo_id = self.get_repository_id()
        if not repo_id:
            print("❌ No se pudo obtener el ID del repositorio")
            return None
        
        # Obtener el owner ID del repositorio para crear el proyecto
        query = """
        query($owner: String!, $name: String!) {
            repository(owner: $owner, name: $name) {
                owner {
                    id
                }
            }
        }
        """
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={
                'query': query,
                'variables': {'owner': self.owner, 'name': self.repo}
            }
        )
        
        if response.status_code != 200:
            print("❌ No se pudo obtener información del repositorio")
            return None
        
        data = response.json()
        if 'errors' in data:
            print(f"❌ Error en GraphQL: {data['errors']}")
            return None
            
        owner_id = data['data']['repository']['owner']['id']
        
        # Crear proyecto - Nota: El campo description ya no se acepta en la creación
        mutation = """
        mutation($ownerId: ID!, $title: String!) {
            createProjectV2(input: {
                ownerId: $ownerId
                title: $title
            }) {
                projectV2 {
                    id
                    title
                    url
                }
            }
        }
        """
        
        variables = {
            'ownerId': owner_id,
            'title': title
        }
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={'query': mutation, 'variables': variables}
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'errors' in data:
                print(f"❌ Error creando proyecto: {data['errors']}")
                return None
            
            project = data['data']['createProjectV2']['projectV2']
            print(f"✅ Proyecto creado: {project['title']}")
            print(f"   URL: {project['url']}")
            
            # Intentar actualizar la descripción después de crear el proyecto
            if description:
                self.update_project_description(project['id'], description)
            
            # Vincular repositorio al proyecto automáticamente
            if self.link_repository_to_project(project['id']):
                print(f"✅ Repositorio vinculado automáticamente al proyecto")
            
            return project['id']
        else:
            print(f"❌ Error en request: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return None

    def update_project_description(self, project_id: str, description: str) -> bool:
        """Actualizar la descripción del proyecto después de crearlo"""
        mutation = """
        mutation($projectId: ID!, $readme: String!) {
            updateProjectV2(input: {
                projectId: $projectId
                readme: $readme
            }) {
                projectV2 {
                    id
                    readme
                }
            }
        }
        """
        
        variables = {
            'projectId': project_id,
            'readme': description
        }
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={'query': mutation, 'variables': variables}
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'errors' not in data:
                print(f"✅ Descripción del proyecto actualizada")
                return True
            else:
                print(f"⚠️  No se pudo actualizar la descripción: {data['errors']}")
        else:
            print(f"⚠️  Error actualizando descripción: {response.status_code}")
            print(f"   Respuesta: {response.text}")
        
        return False

    def link_repository_to_project(self, project_id: str) -> bool:
        """Vincular el repositorio al proyecto"""
        repo_id = self.get_repository_id()
        if not repo_id:
            print("❌ No se pudo obtener el ID del repositorio para vincular")
            return False
        
        # Vincular repositorio al proyecto usando la nueva API
        link_mutation = """
        mutation($projectId: ID!, $repositoryId: ID!) {
            linkProjectV2ToRepository(input: {
                projectId: $projectId
                repositoryId: $repositoryId
            }) {
                repository {
                    id
                }
            }
        }
        """
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={
                'query': link_mutation,
                'variables': {'projectId': project_id, 'repositoryId': repo_id}
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'errors' not in data:
                return True
            else:
                print(f"⚠️  Error vinculando repositorio: {data['errors']}")
        else:
            print(f"⚠️  Error vinculando repositorio: {response.status_code}")
        
        return False

    def add_issues_to_project(self, project_id: str) -> bool:
        """Añadir todas las issues del repositorio al proyecto"""
        print(f"\n📌 Añadiendo issues al proyecto...")
        
        # Obtener todas las issues del repositorio
        issues_url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues"
        response = requests.get(issues_url, headers=self.headers, params={'state': 'all', 'per_page': 100})
        
        if response.status_code != 200:
            print(f"❌ Error obteniendo issues: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False
        
        issues = response.json()
        # Filtrar pull requests (GitHub las devuelve como issues)
        issues = [issue for issue in issues if 'pull_request' not in issue]
        
        if not issues:
            print("ℹ️  No hay issues para añadir al proyecto")
            return True
        
        print(f"📋 Encontradas {len(issues)} issues para añadir al proyecto")
        
        added_count = 0
        for issue in issues:
            if self.add_item_to_project(project_id, issue['node_id']):
                added_count += 1
                print(f"   ✅ Issue #{issue['number']}: {issue['title'][:60]}{'...' if len(issue['title']) > 60 else ''}")
            else:
                print(f"   ⚠️  No se pudo añadir issue #{issue['number']}: {issue['title'][:60]}{'...' if len(issue['title']) > 60 else ''}")
        
        print(f"📊 Issues añadidas al proyecto: {added_count}/{len(issues)}")
        return added_count > 0

    def add_item_to_project(self, project_id: str, item_id: str) -> bool:
        """Añadir un item (issue/PR) específico al proyecto"""
        mutation = """
        mutation($projectId: ID!, $contentId: ID!) {
            addProjectV2ItemById(input: {
                projectId: $projectId
                contentId: $contentId
            }) {
                item {
                    id
                }
            }
        }
        """
        
        variables = {
            'projectId': project_id,
            'contentId': item_id
        }
        
        response = requests.post(
            self.graphql_url,
            headers=self.graphql_headers,
            json={'query': mutation, 'variables': variables}
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'errors' in data:
                # Algunas veces el item ya está en el proyecto
                error_messages = [error.get('message', '') for error in data['errors']]
                if any('already exists' in msg or 'duplicate' in msg.lower() for msg in error_messages):
                    return True  # Consideramos como éxito si ya existe
                print(f"   ⚠️  Error GraphQL: {data['errors']}")
                return False
            return 'data' in data and data['data'] is not None
        else:
            print(f"   ⚠️  Error HTTP añadiendo item: {response.status_code}")
            return False

    def create_issue(self, title: str, body: str, labels: List[str] = None, milestone_number: Optional[int] = None) -> Dict:
        """Crear una issue en el repositorio"""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues"
        
        data = {
            'title': title,
            'body': body
        }
        
        if labels:
            data['labels'] = labels
            
        if milestone_number:
            data['milestone'] = milestone_number
        
        response = requests.post(url, headers=self.headers, json=data)
        
        if response.status_code == 201:
            issue = response.json()
            print(f"✅ Issue creada: {title[:60]}{'...' if len(title) > 60 else ''} (#{issue['number']})")
            return issue
        else:
            print(f"❌ Error creando issue {title[:40]}{'...' if len(title) > 40 else ''}: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return {}

    def create_issues_from_config(self, milestones_config: List[Dict], created_milestones: Dict[str, int]) -> List[Dict]:
        """Crear issues basadas en la configuración y asociarlas a milestones"""
        print(f"\n📝 Creando issues desde configuración...")
        created_issues = []
        
        for milestone_config in milestones_config:
            milestone_title = milestone_config['title']
            milestone_number = created_milestones.get(milestone_title)
            
            if 'issues' in milestone_config:
                print(f"\n📋 Creando issues para milestone: {milestone_title}")
                
                for issue_config in milestone_config['issues']:
                    issue = self.create_issue(
                        title=issue_config['title'],
                        body=issue_config['body'],
                        labels=issue_config.get('labels', []),
                        milestone_number=milestone_number
                    )
                    
                    if issue:
                        created_issues.append(issue)
        
        return created_issues

def main():
    parser = argparse.ArgumentParser(description='Crear GitHub Project y Milestones')
    parser.add_argument('--owner', required=True, help='Owner del repositorio (ej: Toni-Cancela)')
    parser.add_argument('--repo', required=True, help='Nombre del repositorio (ej: FinanZen)')
    parser.add_argument('--token', required=True, help='GitHub Personal Access Token')
    parser.add_argument('--project-title', help='Título del proyecto (default: nombre del repo)')
    parser.add_argument('--config', help='Archivo JSON con configuración de milestones')
    
    args = parser.parse_args()
    
    # Configuración de milestones por defecto para FinanZen
    default_milestones = [
        {
            'title': '🏗️ Setup/Inicialización',
            'description': 'Configuración inicial del proyecto, estructura de directorios, dependencias y testing',
            'due_date': None
        },
        {
            'title': '🚀 MVP Implementation',
            'description': 'Implementación del producto mínimo viable con funcionalidades core',
            'due_date': None
        },
        {
            'title': '⚡ Optimización Financiera',
            'description': 'Funcionalidades avanzadas de optimización y análisis inteligente',
            'due_date': None
        },
        {
            'title': '📊 Gráficas e Info Visual',
            'description': 'Implementación de visualizaciones, gráficas y análisis visual',
            'due_date': None
        }
    ]
    
    # Cargar configuración de milestones si se proporciona
    milestones = default_milestones
    config = None
    if args.config:
        try:
            with open(args.config, 'r', encoding='utf-8') as f:
                config = json.load(f)
                milestones = config.get('milestones', default_milestones)
                # Actualizar título y descripción del proyecto si están en el config
                if 'project' in config:
                    project_title = args.project_title or config['project'].get('title', f"{args.repo} - Project Management")
                    project_description = config['project'].get('description', f"Gestión de proyecto para {args.repo} con milestones y tracking de issues")
        except Exception as e:
            print(f"⚠️  Error cargando configuración: {e}")
            print("Usando configuración por defecto")
    
    if not config:
        project_title = args.project_title or f"{args.repo} - Project Management"
        project_description = f"Gestión de proyecto para {args.repo} con milestones y tracking de issues"
    
    # Inicializar manager
    manager = GitHubProjectManager(args.token, args.owner, args.repo)
    
    print(f"🚀 Configurando proyecto para {args.owner}/{args.repo}")
    print("=" * 50)
    
    # Crear repositorio si no existe
    print("\n📁 Verificando/creando repositorio...")
    if not manager.create_repository_if_not_exists():
        print("❌ No se pudo crear o acceder al repositorio")
        exit(1)
    
    # Crear proyecto
    print("\n📋 Creando GitHub Project...")
    project_id = manager.create_project_v2(project_title, project_description)
    
    # Crear milestones
    print("\n🎯 Creando Milestones...")
    created_milestones = []
    milestones_map = {}  # Para mapear títulos con números
    
    for milestone_config in milestones:
        milestone = manager.create_milestone(
            title=milestone_config['title'],
            description=milestone_config['description'],
            due_date=milestone_config.get('due_date')
        )
        if milestone:
            created_milestones.append(milestone)
            milestones_map[milestone['title']] = milestone['number']
    
    # Crear issues desde configuración si están disponibles
    created_issues = []
    if config and any('issues' in milestone for milestone in milestones):
        created_issues = manager.create_issues_from_config(milestones, milestones_map)
    
    # Añadir issues al proyecto (tanto existentes como nuevas)
    if project_id:
        print("\n📌 Vinculando issues al proyecto...")
        manager.add_issues_to_project(project_id)
    else:
        print("⚠️  No se pudo crear el proyecto, omitiendo vinculación de issues")
    
    print("\n" + "=" * 50)
    print("✅ Configuración completada!")
    print(f"📊 Proyecto creado: {project_title}")
    print(f"🎯 Milestones creados: {len(created_milestones)}")
    print(f"📝 Issues creadas: {len(created_issues)}")
    
    if created_milestones:
        print("\n📝 Milestones creados:")
        for milestone in created_milestones:
            print(f"   • {milestone['title']} (#{milestone['number']})")
    
    print(f"\n🌐 Repositorio: https://github.com/{args.owner}/{args.repo}")
    print(f"📋 Issues: https://github.com/{args.owner}/{args.repo}/issues")
    print(f"🎯 Milestones: https://github.com/{args.owner}/{args.repo}/milestones")

if __name__ == "__main__":
    main()
