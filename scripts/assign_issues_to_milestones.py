#!/usr/bin/env python3
"""
Script para asignar issues existentes a milestones basándose en sus labels
Uso: python assign_issues_to_milestones.py --owner OWNER --repo REPO --token GITHUB_TOKEN
"""

import argparse
import requests
import sys
from typing import Dict, List

class GitHubIssueManager:
    def __init__(self, token: str, owner: str, repo: str):
        self.token = token
        self.owner = owner
        self.repo = repo
        self.headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
        }
        self.base_url = 'https://api.github.com'

    def get_milestones(self) -> Dict[str, int]:
        """Obtener todos los milestones del repositorio"""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/milestones"
        response = requests.get(url, headers=self.headers)
        
        if response.status_code == 200:
            milestones = response.json()
            return {milestone['title']: milestone['number'] for milestone in milestones}
        else:
            print(f"❌ Error obteniendo milestones: {response.status_code}")
            return {}

    def get_issues(self) -> List[Dict]:
        """Obtener todas las issues abiertas del repositorio"""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues"
        params = {'state': 'open', 'per_page': 100}
        
        all_issues = []
        page = 1
        
        while True:
            params['page'] = page
            response = requests.get(url, headers=self.headers, params=params)
            
            if response.status_code == 200:
                issues = response.json()
                if not issues:
                    break
                
                # Filtrar pull requests (GitHub las devuelve como issues)
                issues = [issue for issue in issues if 'pull_request' not in issue]
                all_issues.extend(issues)
                page += 1
            else:
                print(f"❌ Error obteniendo issues: {response.status_code}")
                break
        
        return all_issues

    def assign_issue_to_milestone(self, issue_number: int, milestone_number: int) -> bool:
        """Asignar una issue a un milestone"""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues/{issue_number}"
        data = {'milestone': milestone_number}
        
        response = requests.patch(url, headers=self.headers, json=data)
        
        if response.status_code == 200:
            return True
        else:
            print(f"❌ Error asignando issue #{issue_number} a milestone: {response.status_code}")
            return False

def main():
    parser = argparse.ArgumentParser(description='Asignar issues a milestones basándose en labels')
    parser.add_argument('--owner', required=True, help='Owner del repositorio')
    parser.add_argument('--repo', required=True, help='Nombre del repositorio')
    parser.add_argument('--token', required=True, help='GitHub Personal Access Token')
    parser.add_argument('--dry-run', action='store_true', help='Solo mostrar qué se haría, sin hacer cambios')
    
    args = parser.parse_args()
    
    # Mapeo de labels a milestones
    label_to_milestone = {
        'milestone-1-setup': '🏗️ Setup/Inicialización',
        'milestone-2-mvp': '🚀 MVP Implementation',
        'milestone-3-optimization': '⚡ Optimización Financiera',
        'milestone-4-charts': '📊 Gráficas e Info Visual'
    }
    
    manager = GitHubIssueManager(args.token, args.owner, args.repo)
    
    print(f"🔍 Analizando issues en {args.owner}/{args.repo}")
    print("=" * 50)
    
    # Obtener milestones existentes
    print("📋 Obteniendo milestones...")
    milestones = manager.get_milestones()
    
    if not milestones:
        print("❌ No se encontraron milestones en el repositorio")
        return
    
    print(f"✅ Encontrados {len(milestones)} milestones:")
    for title in milestones.keys():
        print(f"   • {title}")
    
    # Obtener issues
    print("\n🎯 Obteniendo issues...")
    issues = manager.get_issues()
    
    if not issues:
        print("❌ No se encontraron issues en el repositorio")
        return
    
    print(f"✅ Encontradas {len(issues)} issues")
    
    # Procesar asignaciones
    print("\n🔄 Procesando asignaciones...")
    assignments = []
    
    for issue in issues:
        issue_labels = [label['name'] for label in issue['labels']]
        issue_number = issue['number']
        issue_title = issue['title']
        current_milestone = issue.get('milestone')
        
        # Buscar label de milestone
        milestone_label = None
        for label in issue_labels:
            if label in label_to_milestone:
                milestone_label = label
                break
        
        if milestone_label:
            target_milestone_title = label_to_milestone[milestone_label]
            target_milestone_number = milestones.get(target_milestone_title)
            
            if target_milestone_number:
                # Verificar si ya está asignada al milestone correcto
                if current_milestone and current_milestone['title'] == target_milestone_title:
                    print(f"✅ Issue #{issue_number} ya está en el milestone correcto: {target_milestone_title}")
                else:
                    assignments.append({
                        'issue_number': issue_number,
                        'issue_title': issue_title,
                        'milestone_number': target_milestone_number,
                        'milestone_title': target_milestone_title,
                        'label': milestone_label
                    })
            else:
                print(f"⚠️  Milestone '{target_milestone_title}' no encontrado para issue #{issue_number}")
        else:
            print(f"⚠️  Issue #{issue_number} no tiene label de milestone: {issue_title}")
    
    if not assignments:
        print("\n✅ Todas las issues ya están correctamente asignadas")
        return
    
    print(f"\n📝 Se realizarán {len(assignments)} asignaciones:")
    for assignment in assignments:
        status = "🔍 [DRY RUN]" if args.dry_run else "🔄"
        print(f"   {status} Issue #{assignment['issue_number']} → {assignment['milestone_title']}")
        print(f"      '{assignment['issue_title']}'")
    
    if args.dry_run:
        print("\n🔍 Modo dry-run activado. No se realizaron cambios.")
        print("   Ejecuta sin --dry-run para aplicar los cambios.")
        return
    
    # Confirmar antes de proceder
    print(f"\n⚠️  ¿Continuar con las {len(assignments)} asignaciones? (y/N): ", end="")
    confirmation = input().strip().lower()
    
    if confirmation != 'y':
        print("❌ Operación cancelada")
        return
    
    # Realizar asignaciones
    print("\n🚀 Realizando asignaciones...")
    success_count = 0
    
    for assignment in assignments:
        success = manager.assign_issue_to_milestone(
            assignment['issue_number'],
            assignment['milestone_number']
        )
        
        if success:
            success_count += 1
            print(f"✅ Issue #{assignment['issue_number']} asignada a '{assignment['milestone_title']}'")
        else:
            print(f"❌ Error asignando issue #{assignment['issue_number']}")
    
    print("\n" + "=" * 50)
    print(f"✅ Proceso completado!")
    print(f"📊 Asignaciones exitosas: {success_count}/{len(assignments)}")

if __name__ == "__main__":
    main()
