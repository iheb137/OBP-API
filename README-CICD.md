# Pipeline CI/CD/CT pour OBP-API

Ce projet implémente une pipeline CI/CD/CT complète pour l'application Open Bank Project API (OBP-API), dans le cadre d'un stage DevOps chez Biotight. La pipeline couvre l'intégration continue, le déploiement continu et les tests continus, avec un focus sur les spécificités du secteur bancaire.

## Structure du projet

```
OBP-API/
├── Jenkinsfile                # Pipeline Jenkins complète
├── kubernetes/                # Configurations Kubernetes
│   ├── namespace.yaml        # Définition du namespace
│   ├── configmap.yaml        # ConfigMap pour les configurations non-sensibles
│   ├── secret.yaml           # Secret pour les informations sensibles
│   ├── deployment.yaml       # Déploiement de l'application
│   ├── service.yaml          # Service pour exposer l'application
│   ├── ingress.yaml          # Ingress pour l'accès externe
│   └── README.md             # Documentation Kubernetes
├── monitoring/                # Stack de monitoring
│   ├── prometheus/           # Configuration Prometheus
│   ├── grafana/              # Configuration Grafana
│   ├── alertmanager/         # Configuration AlertManager
│   ├── docker-compose.yml    # Composition des services
│   └── README.md             # Documentation monitoring
├── tests/                     # Tests automatisés
│   ├── postman/              # Tests d'intégration avec Postman
│   ├── jmeter/               # Tests de charge avec JMeter
│   └── README.md             # Documentation des tests
├── sonar-project.properties   # Configuration SonarQube
└── README-CICD.md             # Ce fichier
```

## Pipeline CI/CD/CT

La pipeline Jenkins (`Jenkinsfile`) implémente un workflow complet avec les étapes suivantes :

1. **Checkout** : Récupération du code source depuis le dépôt Git
2. **Préparation de l'environnement** : Configuration des outils et variables
3. **Nettoyage et compilation** : Build Maven avec nettoyage du cache
4. **Tests unitaires** : Exécution des tests unitaires avec JUnit
5. **Analyse de code** : Analyse statique avec SonarQube
6. **Construction de l'image Docker** : Création et publication de l'image
7. **Tests d'intégration** : Vérification des API avec Postman/Newman
8. **Tests de charge** : Évaluation des performances avec JMeter
9. **Déploiement sur Kubernetes** : Déploiement sur Minikube
10. **Mise à jour Jira** : Mise à jour automatique des tickets

## Déploiement Kubernetes

L'application est déployée sur Kubernetes (Minikube) avec les ressources suivantes :

- **Namespace** : Isolation logique (`biat-banking`)
- **ConfigMap** : Configurations non-sensibles
- **Secret** : Informations sensibles (identifiants, clés)
- **Deployment** : Déploiement de l'application avec 2 répliques
- **Service** : Exposition interne de l'application
- **Ingress** : Exposition externe avec TLS

Consultez le fichier `kubernetes/README.md` pour plus de détails.

## Monitoring

La stack de monitoring comprend :

- **Prometheus** : Collecte et stockage des métriques
- **Grafana** : Visualisation des métriques
- **AlertManager** : Gestion des alertes et notifications
- **Exporters** : Node Exporter, cAdvisor, JMX Exporter

Consultez le fichier `monitoring/README.md` pour plus de détails.

## Tests automatisés

Le projet inclut plusieurs types de tests :

- **Tests unitaires** : Exécutés via Maven
- **Tests d'intégration** : Collection Postman/Newman
- **Tests de charge** : Plan de test JMeter

Consultez le fichier `tests/README.md` pour plus de détails.

## Analyse de code

L'analyse statique du code est réalisée avec SonarQube, configuré via le fichier `sonar-project.properties`. L'analyse inclut :

- Qualité du code
- Couverture des tests
- Vulnérabilités de sécurité
- Dette technique

## Prérequis

- **Jenkins** : v2.346.x ou supérieur
- **Docker** : v20.10.x ou supérieur
- **Kubernetes** : v1.23.x ou supérieur (Minikube v1.25.x)
- **Maven** : v3.8.x ou supérieur
- **JDK** : v11 ou supérieur
- **SonarQube** : v9.x ou supérieur
- **Node.js** : v16.x ou supérieur (pour Newman)
- **JMeter** : v5.5 ou supérieur

## Installation et configuration

### Jenkins

1. Installez les plugins Jenkins requis :
   - Pipeline
   - Docker Pipeline
   - Kubernetes CLI
   - SonarQube Scanner
   - JUnit
   - Email Extension
   - Jira Integration

2. Configurez les credentials Jenkins :
   - `docker-hub-credentials` : Identifiants Docker Hub
   - `sonarqube-token` : Token d'accès SonarQube
   - `jira-credentials` : Identifiants Jira
   - `k8s-config` : Configuration Kubernetes

3. Configurez les outils Jenkins :
   - Maven 3.9.6
   - JDK 17
   - SonarQube Scanner

### Kubernetes (Minikube)

1. Démarrez Minikube :
   ```bash
   minikube start --driver=docker --cpus=4 --memory=8g
   ```

2. Activez les addons nécessaires :
   ```bash
   minikube addons enable ingress
   minikube addons enable metrics-server
   ```

3. Créez le namespace et déployez l'application :
   ```bash
   kubectl apply -f kubernetes/namespace.yaml
   kubectl apply -f kubernetes/ -n biat-banking
   ```

### Monitoring

1. Démarrez la stack de monitoring :
   ```bash
   cd monitoring
   docker-compose up -d
   ```

2. Accédez aux interfaces :
   - Prometheus : http://localhost:9090
   - Grafana : http://localhost:3000 (admin/admin)
   - AlertManager : http://localhost:9093

## Utilisation

### Exécution manuelle de la pipeline

1. Créez un nouveau pipeline Jenkins en utilisant le `Jenkinsfile` de ce projet
2. Lancez la pipeline avec les paramètres souhaités

### Exécution automatique

La pipeline est configurée pour s'exécuter automatiquement lors d'un push sur les branches principales (develop, main) ou lors de la création d'une pull request.

### Tests manuels

1. Tests d'intégration :
   ```bash
   cd tests/postman
   ./run-tests.ps1
   ```

2. Tests de charge :
   ```bash
   cd tests/jmeter
   ./run-load-tests.ps1
   ```

## Dépannage

### Pipeline Jenkins

- Vérifiez les logs Jenkins pour identifier les erreurs
- Assurez-vous que tous les credentials sont correctement configurés
- Vérifiez l'accès aux registres Docker et aux dépôts Maven

### Déploiement Kubernetes

- Vérifiez l'état des pods : `kubectl get pods -n biat-banking`
- Consultez les logs des pods : `kubectl logs <pod-name> -n biat-banking`
- Vérifiez les événements : `kubectl get events -n biat-banking`

### Monitoring

- Vérifiez que les exporters sont accessibles depuis Prometheus
- Consultez les logs des conteneurs de monitoring

## Contribution

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -m 'Ajout d'une nouvelle fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créez une Pull Request

## Licence

Ce projet est distribué sous licence MIT. Voir le fichier `LICENSE` pour plus d'informations.

## Contact

Pour toute question ou suggestion, veuillez contacter l'équipe DevOps de Biotight.