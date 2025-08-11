# Tests pour OBP-API

Ce répertoire contient les différents tests pour l'application OBP-API, organisés par type de test.

## Structure

```
tests/
├── postman/                # Tests d'intégration avec Postman/Newman
│   ├── OBP-API-Tests.postman_collection.json    # Collection de tests API
│   ├── OBP-API-Environment.postman_environment.json  # Variables d'environnement
│   └── run-tests.ps1       # Script pour exécuter les tests
├── jmeter/                 # Tests de charge avec JMeter
│   ├── OBP-API-Load-Test.jmx  # Plan de test JMeter
│   └── run-load-tests.ps1  # Script pour exécuter les tests de charge
└── README.md               # Ce fichier
```

## Prérequis

- **Postman/Newman** : Pour les tests d'intégration
  - Node.js et npm installés
  - Newman installé globalement (`npm install -g newman`)
  - Reporter HTML installé (`npm install -g newman-reporter-htmlextra`)

- **JMeter** : Pour les tests de charge
  - Java JDK 8 ou supérieur installé
  - Apache JMeter 5.5 ou supérieur installé
  - Chemin vers JMeter configuré dans le script `run-load-tests.ps1`

## Tests d'intégration (Postman/Newman)

### Description

Les tests d'intégration vérifient que les différentes API de l'application fonctionnent correctement. La collection Postman inclut des tests pour :

- Authentification (Direct Login)
- Opérations sur les banques
- Opérations sur les comptes
- Opérations sur les transactions

### Exécution

1. Assurez-vous que l'application OBP-API est en cours d'exécution
2. Ouvrez PowerShell et naviguez vers le répertoire `tests/postman`
3. Exécutez le script : `./run-tests.ps1`
4. Les rapports seront générés dans le répertoire `target/newman`

### Personnalisation

Vous pouvez modifier le fichier d'environnement `OBP-API-Environment.postman_environment.json` pour ajuster les paramètres comme :

- URL de base (`baseUrl`)
- Identifiants de connexion (`username`, `password`, `consumer_key`)

## Tests de charge (JMeter)

### Description

Les tests de charge évaluent les performances de l'application sous différentes conditions de charge. Le plan de test JMeter inclut :

- Authentification
- Récupération de la liste des banques (10 utilisateurs, 10 itérations)
- Récupération des détails d'une banque (20 utilisateurs, 5 itérations)

### Exécution

1. Assurez-vous que l'application OBP-API est en cours d'exécution
2. Modifiez le script `run-load-tests.ps1` pour définir le chemin correct vers votre installation JMeter
3. Ouvrez PowerShell et naviguez vers le répertoire `tests/jmeter`
4. Exécutez le script : `./run-load-tests.ps1`
5. Les résultats et rapports seront générés dans le répertoire `target/jmeter`

### Personnalisation

Vous pouvez ouvrir le fichier `OBP-API-Load-Test.jmx` avec l'interface graphique de JMeter pour :

- Modifier les variables d'environnement (hôte, port, identifiants)
- Ajuster le nombre d'utilisateurs et d'itérations
- Ajouter de nouveaux scénarios de test

## Intégration avec Jenkins

Les tests sont automatiquement exécutés dans le pipeline Jenkins défini dans le `Jenkinsfile` à la racine du projet. Les résultats des tests sont publiés sous forme de rapports dans Jenkins.

## Dépannage

### Tests Postman/Newman

- Vérifiez que Newman est correctement installé : `newman --version`
- Assurez-vous que l'application est accessible à l'URL définie dans l'environnement
- Vérifiez les identifiants de connexion dans le fichier d'environnement

### Tests JMeter

- Vérifiez que JMeter est correctement installé et que le chemin est correct dans le script
- Assurez-vous que l'application est accessible à l'URL définie dans les variables du test
- Pour les problèmes de mémoire, ajustez les paramètres JVM dans le fichier `jmeter.bat`