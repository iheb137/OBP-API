# Monitoring pour OBP-API

Ce répertoire contient la configuration pour la surveillance de l'application OBP-API, utilisant la stack Prometheus, Grafana, AlertManager et des exporters.

## Structure

```
monitoring/
├── alertmanager/                # Configuration AlertManager
│   └── config.yml              # Configuration des alertes et notifications
├── grafana/                     # Configuration Grafana
│   ├── dashboards/             # Dashboards Grafana
│   │   └── obp-api-dashboard.json  # Dashboard principal pour OBP-API
│   └── provisioning/           # Configuration automatique
│       ├── dashboards/         # Provisionnement des dashboards
│       │   └── dashboard.yml   # Configuration des sources de dashboards
│       └── datasources/        # Provisionnement des sources de données
│           └── prometheus.yml  # Configuration de la source Prometheus
├── prometheus/                  # Configuration Prometheus
│   ├── prometheus.yml         # Configuration principale
│   └── rules/                 # Règles d'alerte
│       └── obp-api-alerts.yml # Règles d'alerte pour OBP-API
├── docker-compose.yml           # Composition des services de monitoring
└── README.md                    # Ce fichier
```

## Composants

### Prometheus

Prometheus est utilisé pour collecter et stocker les métriques de l'application OBP-API et de l'infrastructure. Il est configuré pour scraper les métriques de :

- L'application OBP-API (via JMX Exporter)
- Node Exporter (métriques système)
- cAdvisor (métriques des conteneurs)
- Jenkins
- Kubernetes (si déployé dans Minikube)

### Grafana

Grafana fournit des tableaux de bord visuels pour les métriques collectées par Prometheus. Le dashboard principal inclut :

- Taux de requêtes HTTP
- Temps de réponse
- Utilisation de la mémoire JVM
- Utilisation CPU
- Nombre de threads
- Temps de garbage collection

### AlertManager

AlertManager gère les alertes envoyées par Prometheus et les achemine vers les canaux de notification appropriés :

- Email pour les alertes critiques
- Slack pour les alertes de niveau warning

### Exporters

- **Node Exporter** : Collecte des métriques système (CPU, mémoire, disque, réseau)
- **cAdvisor** : Collecte des métriques des conteneurs Docker
- **JMX Exporter** : Intégré à l'application OBP-API pour exposer les métriques JVM

## Déploiement

### Prérequis

- Docker et Docker Compose installés
- Accès réseau aux ports 9090 (Prometheus), 3000 (Grafana), 9093 (AlertManager)

### Démarrage

1. Assurez-vous que l'application OBP-API est configurée avec JMX Exporter
2. Démarrez la stack de monitoring :

```bash
cd monitoring
docker-compose up -d
```

3. Accédez aux interfaces :
   - Prometheus : http://localhost:9090
   - Grafana : http://localhost:3000 (identifiants par défaut : admin/admin)
   - AlertManager : http://localhost:9093

## Configuration

### Personnalisation des alertes

Modifiez le fichier `prometheus/rules/obp-api-alerts.yml` pour ajuster les seuils d'alerte selon vos besoins.

### Configuration des notifications

Modifiez le fichier `alertmanager/config.yml` pour configurer :

- Les destinataires des emails
- Le webhook Slack
- Les délais de notification

### Ajout de dashboards

Placez vos fichiers JSON de dashboard dans le répertoire `grafana/dashboards/` et mettez à jour `grafana/provisioning/dashboards/dashboard.yml` si nécessaire.

## Intégration avec Jenkins

Le monitoring est intégré au pipeline CI/CD dans Jenkins. Après chaque déploiement réussi, Jenkins vérifie l'état de santé de l'application en interrogeant les métriques Prometheus.

## Dépannage

### Prometheus

- Vérifiez l'accessibilité des cibles : http://localhost:9090/targets
- Consultez les logs : `docker-compose logs prometheus`

### Grafana

- Vérifiez la connexion à la source de données Prometheus
- Consultez les logs : `docker-compose logs grafana`

### AlertManager

- Vérifiez la configuration : http://localhost:9093/#/status
- Testez les notifications manuellement
- Consultez les logs : `docker-compose logs alertmanager`