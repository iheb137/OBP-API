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
                // == CORRECTION FINALE : On écrit le bon contenu au bon endroit ==
                // ==========================================================
                echo 'Creating a valid properties file for tests...'
                writeFile(
                    // On utilise le chemin du sous-module 'obp-api'
                    file: 'obp-api/src/test/resources/props/test.props',
                    text: '''
# Configuration minimale pour que les tests OBP-API se lancent
hostname="http://127.0.0.1"
db.driver=org.h2.Driver
db.url=jdbc:h2:mem:OBPTest;DB_CLOSE_DELAY=-1
elastic_search_host=localhost
'''
                 )

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

