# Configuration Jenkins pour OBP-API

Ce répertoire contient les fichiers nécessaires pour configurer un serveur Jenkins dédié au projet OBP-API.

## Contenu

- `docker-compose.yml` : Configuration Docker Compose pour déployer Jenkins
- `Dockerfile` : Image Docker personnalisée avec les outils nécessaires
- `plugins.txt` : Liste des plugins Jenkins à installer
- `jenkins.yaml` : Configuration Jenkins as Code (JCasC)

## Prérequis

- Docker et Docker Compose installés
- Git installé
- Accès Internet pour télécharger les images et plugins

## Installation

1. Clonez ce dépôt Git :
   ```bash
   git clone https://github.com/votre-organisation/OBP-API.git
   cd OBP-API/jenkins
   ```

2. Construisez et démarrez le conteneur Jenkins :
   ```bash
   docker-compose up -d
   ```

3. Accédez à Jenkins via votre navigateur :
   ```
   http://localhost:18080
   ```

## Configuration manuelle supplémentaire

Après le démarrage initial, vous devrez configurer manuellement :

1. **Credentials** :
   - `docker-hub-credentials` : Identifiants Docker Hub
   - `sonarqube-token` : Token d'accès SonarQube
   - `jira-credentials` : Identifiants Jira
   - `k8s-config` : Configuration Kubernetes

2. **URL du dépôt Git** :
   - Modifiez l'URL du dépôt Git dans `jenkins.yaml` pour pointer vers votre dépôt

## Utilisation

1. Créez un nouveau pipeline Jenkins en utilisant le `Jenkinsfile` du projet
2. Lancez la pipeline avec les paramètres souhaités :
   - Environnement : dev, test ou prod
   - Exécution des tests : activée
   - Déploiement sur Kubernetes : activé

## Dépannage

- **Problèmes d'accès à Docker** : Vérifiez que le socket Docker est correctement monté
- **Plugins manquants** : Ajoutez-les dans le fichier `plugins.txt` et reconstruisez l'image
- **Erreurs de pipeline** : Consultez les logs Jenkins pour identifier les problèmes

## Maintenance

- **Mise à jour de Jenkins** : Modifiez la version dans `docker-compose.yml` et reconstruisez
- **Sauvegarde** : Le volume `jenkins_home` contient toutes les données à sauvegarder