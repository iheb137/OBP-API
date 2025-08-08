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
                // == AJOUT : On crée le fichier de configuration manquant ==
                // ==========================================================
                writeFile(
                    file: 'obp-api/src/test/resources/props/test.props',
                    text: '''
hostname=http://127.0.0.1:8080
db.driver=org.h2.Driver
db.url=jdbc:h2:mem:OBPTest;DB_CLOSE_DELAY=-1
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

