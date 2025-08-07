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

        stage('Package with Maven') { // Étape renommée pour plus de clarté
            steps {
                echo 'Packaging the application with Maven...'
                // 'package' crée le fichier .war nécessaire pour l'image Docker
                sh 'mvn -B clean package -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
        }

        // ===============================================
        // ==         NOUVELLE ÉTAPE CI-DESSOUS         ==
        // ===============================================
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker image...'
                // On nomme l'image avec le format 'votre_nom/nom_app'
                // C'est une bonne pratique pour Docker Hub.
                sh 'docker build -t iheb137/obp-api:latest .'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}


