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

        stage('Package with Maven') {
            steps {
                echo 'Packaging the application with Maven...'
                sh 'mvn -B clean package -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            steps {
                // ==========================================================
                // == CORRECTION : On copie le fichier de config existant  ==
                // ==========================================================
                echo 'Preparing test configuration...'
                // On copie le modèle de configuration vers le nom attendu par les tests.
                // Le chemin est relatif au sous-module 'obp-api'.
                sh 'cp obp-api/src/main/resources/props/sample.props.template obp-api/src/test/resources/props/test.props'

                echo 'Running unit tests...'
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker image...'
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

