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

        stage('Package Application') {
            steps {
                echo 'Building and installing all modules...'
                // AJOUT DE -U pour forcer la mise à jour des dépendances
                sh 'mvn -B clean install -DskipTests -U'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker image...'
                sh 'docker build -t iheb137/obp-api:latest .'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running fast unit tests...'
                sh 'mvn surefire:test'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
