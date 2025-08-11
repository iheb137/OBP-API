# Configuration Kubernetes pour OBP-API

Ce répertoire contient les fichiers de configuration Kubernetes nécessaires pour déployer l'application OBP-API dans un environnement Kubernetes.

## Structure des fichiers

- `namespace.yaml` : Définit l'espace de noms `biat-banking` pour isoler les ressources de l'application
- `configmap.yaml` : Contient les configurations non-sensibles de l'application
- `secret.yaml` : Contient les informations sensibles (mots de passe, clés d'API) encodées en base64
- `deployment.yaml` : Définit le déploiement de l'application avec les paramètres de ressources et les sondes de santé
- `service.yaml` : Expose l'application à l'intérieur du cluster
- `ingress.yaml` : Expose l'application à l'extérieur du cluster avec HTTPS

## Prérequis

- Un cluster Kubernetes fonctionnel (Minikube, AKS, EKS, GKE, etc.)
- kubectl configuré pour communiquer avec votre cluster
- Un registre Docker pour stocker les images (configuré dans Jenkins)

## Déploiement manuel

Pour déployer manuellement l'application, exécutez les commandes suivantes :

```bash
# Créer l'espace de noms
kubectl apply -f namespace.yaml

# Déployer les configurations
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

# Déployer l'application
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

## Vérification du déploiement

Pour vérifier que l'application est correctement déployée :

```bash
# Vérifier le statut du déploiement
kubectl rollout status deployment/obp-api -n biat-banking

# Vérifier les pods
kubectl get pods -n biat-banking

# Vérifier le service
kubectl get svc -n biat-banking

# Vérifier l'ingress
kubectl get ingress -n biat-banking
```

## Accès à l'application

Une fois déployée, l'application sera accessible à l'adresse suivante :

- https://api.banking.biat-it.com

## Intégration avec Jenkins

Ces fichiers sont utilisés par le pipeline Jenkins pour automatiser le déploiement. Le pipeline remplacera les variables d'environnement (comme `${ENVIRONMENT}`) par les valeurs appropriées avant d'appliquer les configurations.

## Surveillance

L'application est configurée avec des sondes de santé (readiness et liveness) qui permettent à Kubernetes de surveiller l'état de l'application et de redémarrer les pods en cas de problème.