# Configuration Jenkins pour OBP-API

Ce document décrit la configuration de Jenkins pour le projet OBP-API, incluant l'installation, la configuration et l'utilisation de Jenkins pour la pipeline CI/CD.

## Table des matières

1. [Prérequis](#prérequis)
2. [Installation de Jenkins](#installation-de-jenkins)
3. [Configuration de Jenkins](#configuration-de-jenkins)
4. [Pipeline CI/CD](#pipeline-cicd)
5. [Dépannage](#dépannage)

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- Docker Desktop
- Git
- PowerShell (Windows) ou Bash (Linux/macOS)

## Installation de Jenkins

Nous utilisons Docker pour déployer Jenkins, ce qui simplifie l'installation et la configuration.

### Structure des fichiers

Le répertoire `jenkins/` contient tous les fichiers nécessaires pour configurer Jenkins :

```
jenkins/
├── docker-compose.yml    # Configuration Docker Compose pour Jenkins
├── Dockerfile            # Image Docker personnalisée avec les outils nécessaires
├── plugins.txt           # Liste des plugins Jenkins à installer
├── jenkins.yaml          # Configuration Jenkins as Code (JCasC)
├── setup.ps1             # Script principal de configuration (Windows)
├── start-jenkins.ps1     # Script pour démarrer Jenkins (Windows)
├── stop-jenkins.ps1      # Script pour arrêter Jenkins (Windows)
├── prepare-git.ps1       # Script pour nettoyer le dépôt Git (Windows)
├── setup-credentials.ps1 # Script pour configurer les credentials (Windows)
├── setup-job.ps1         # Script pour configurer le job Jenkins (Windows)
└── README.md             # Documentation spécifique au répertoire jenkins/
```

### Installation avec Docker

1. Clonez le dépôt Git si ce n'est pas déjà fait :
   ```powershell
   git clone https://github.com/votre-organisation/OBP-API.git
   cd OBP-API
   ```

2. Exécutez le script de configuration principal :
   ```powershell
   cd jenkins
   .\setup.ps1
   ```

3. Suivez les instructions à l'écran pour :
   - Nettoyer le dépôt Git et préparer le projet
   - Démarrer Jenkins
   - Configurer les credentials Jenkins
   - Configurer le job Jenkins pour OBP-API

4. Accédez à Jenkins via votre navigateur :
   ```
   http://localhost:18080
   ```

## Configuration de Jenkins

### Credentials nécessaires

Les credentials suivants doivent être configurés dans Jenkins :

1. **docker-hub-credentials** : Identifiants Docker Hub pour publier les images
2. **sonarqube-token** : Token d'accès SonarQube pour l'analyse de code
3. **jira-credentials** : Identifiants Jira pour la mise à jour des tickets
4. **k8s-config** : Configuration Kubernetes pour le déploiement

Vous pouvez configurer ces credentials manuellement via l'interface Jenkins ou utiliser le script `setup-credentials.ps1`.

### Outils configurés

L'image Jenkins est préconfigurée avec les outils suivants :

- Docker CLI
- kubectl
- Maven
- JDK

### Plugins installés

Les plugins Jenkins essentiels sont installés automatiquement, notamment :

- Pipeline
- Git
- Docker
- Kubernetes
- SonarQube Scanner
- Jira

## Pipeline CI/CD

La pipeline CI/CD est définie dans le fichier `Jenkinsfile` à la racine du projet. Elle comprend les étapes suivantes :

1. **Checkout** : Récupération du code source depuis Git
2. **Préparation** : Configuration de l'environnement
3. **Compilation** : Compilation du projet avec Maven
4. **Tests unitaires** : Exécution des tests unitaires
5. **Analyse de code** : Analyse statique du code avec SonarQube
6. **Construction Docker** : Construction de l'image Docker
7. **Publication Docker** : Publication de l'image sur Docker Hub
8. **Tests d'intégration** : Exécution des tests d'intégration
9. **Déploiement Kubernetes** : Déploiement sur Kubernetes
10. **Mise à jour Jira** : Mise à jour des tickets Jira

### Paramètres de la pipeline

La pipeline accepte les paramètres suivants :

- **ENVIRONMENT** : Environnement de déploiement (dev, test, prod)
- **RUN_TESTS** : Exécuter les tests (true/false)
- **DEPLOY_TO_K8S** : Déployer sur Kubernetes (true/false)

## Dépannage

### Problèmes courants

1. **Jenkins ne démarre pas** :
   - Vérifiez que Docker est en cours d'exécution
   - Vérifiez les logs Docker : `docker logs jenkins-jenkins`
   - Vérifiez les ports utilisés : `netstat -ano | findstr 18080`

2. **Échec de la pipeline** :
   - Vérifiez les credentials configurés
   - Vérifiez les logs de la pipeline dans Jenkins
   - Vérifiez la configuration des outils (Maven, JDK)

3. **Problèmes de connexion à Docker** :
   - Vérifiez que le socket Docker est correctement monté
   - Vérifiez les permissions du socket Docker

### Logs Jenkins

Pour consulter les logs Jenkins :

```powershell
docker logs jenkins-jenkins
```

Pour consulter les logs d'un job spécifique, utilisez l'interface Jenkins ou exécutez :

```powershell
docker exec jenkins-jenkins cat /var/jenkins_home/jobs/OBP-API-Pipeline/builds/last/log
```

## Ressources supplémentaires

- [Documentation Jenkins](https://www.jenkins.io/doc/)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Kubernetes](https://kubernetes.io/docs/)
- [Documentation SonarQube](https://docs.sonarqube.org/)