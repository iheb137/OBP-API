pipeline {
    agent any
    tools {
        maven 'Maven-3.9.6'
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/iheb137/OBP-API.git', branch: 'develop'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B clean package -DskipTests'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t iheb137/obp-api:latest .'
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                        sh 'docker push iheb137/obp-api:latest'
                    }
                }
            }
        }
    }
}
