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
                // On utilise 'install' pour installer les modules dans le dépôt local
                // Cela permet aux modules de se trouver entre eux
                sh 'mvn -B clean install -DskipTests'
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

