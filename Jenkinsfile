pipeline {
    agent any

    tools {
        maven 'Maven-3.9.6'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out from Git...'
            }
        }

        // Étape 1 : On compile et on crée le .war, mais on saute les tests
        stage('Package Application') {
            steps {
                echo 'Packaging the application and skipping tests...'
                sh 'mvn -B clean package -DskipTests'
            }
        }

        // Étape 2 : On construit l'image Docker à partir du résultat
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker image...'
                // On utilise le Dockerfile qui se trouve à la racine du projet
                sh 'docker build -t iheb137/obp-api:latest .'
            }
        }

        // Étape 3 (Optionnelle mais recommandée) : On lance les tests unitaires rapides
        // pour vérifier la logique de base.
        stage('Run Unit Tests') {
            steps {
                echo 'Running fast unit tests...'
                // Cette commande ne lance que les tests les plus simples
                sh 'mvn surefire:test'
            }
        }
    }

    post {
        always {
            // Cette section s'exécute toujours à la fin
            echo 'Pipeline finished.'
            // On peut ajouter un nettoyage ici si nécessaire
            // cleanWs()
        }
    }
}

