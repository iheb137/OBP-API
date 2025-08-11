# Guide Rapide - Configuration Jenkins pour OBP-API

Ce guide rapide vous aidera à configurer Jenkins pour le projet OBP-API en quelques étapes simples.

## Étape 1 : Vérifier les prérequis

Assurez-vous d'avoir installé :
- Docker Desktop
- Git

Exécutez le script de vérification des prérequis :
```powershell
.\check-prerequisites.ps1
```

## Étape 2 : Nettoyer le dépôt Git (si nécessaire)

Si vous souhaitez repartir d'un dépôt propre :
```powershell
.\prepare-git.ps1
```

Ce script sauvegarde vos fichiers importants avant de nettoyer le dépôt.

## Étape 3 : Démarrer Jenkins

```powershell
.\start-jenkins.ps1
```

Jenkins sera accessible à l'adresse : http://localhost:18080

## Étape 4 : Personnaliser le Jenkinsfile

Adaptez le Jenkinsfile à votre environnement :
```powershell
.\update-jenkinsfile.ps1
```

## Étape 5 : Configurer les credentials Jenkins

Configurez les identifiants nécessaires pour la pipeline :
```powershell
.\setup-credentials.ps1
```

## Étape 6 : Configurer le job Jenkins

Créez le job Jenkins pour OBP-API :
```powershell
.\setup-job.ps1
```

## Étape 7 : Exécuter la pipeline

1. Accédez à Jenkins : http://localhost:18080
2. Ouvrez le job "OBP-API-Pipeline"
3. Cliquez sur "Build with Parameters"
4. Sélectionnez les paramètres souhaités
5. Cliquez sur "Build"

## Étape 8 : Arrêter Jenkins (si nécessaire)

```powershell
.\stop-jenkins.ps1
```

## Utilisation du script de configuration

Pour une configuration guidée, utilisez le script principal :
```powershell
.\setup.ps1
```

Ce script vous guidera à travers toutes les étapes de configuration avec un menu interactif.

## Dépannage

### Jenkins ne démarre pas
- Vérifiez que Docker est en cours d'exécution
- Vérifiez les logs : `docker logs jenkins-jenkins`
- Vérifiez que les ports 18080 et 50000 sont disponibles

### Échec de la pipeline
- Vérifiez les credentials configurés
- Vérifiez les logs de la pipeline dans Jenkins
- Assurez-vous que le Jenkinsfile est correctement configuré

### Problèmes de connexion à Docker
- Vérifiez que le socket Docker est correctement monté
- Redémarrez Docker Desktop

## Ressources

- Documentation Jenkins : https://www.jenkins.io/doc/
- Documentation Docker : https://docs.docker.com/
- Documentation OBP-API : voir README.md à la racine du projet