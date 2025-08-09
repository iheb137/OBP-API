pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo '🔍 Checkout du code...'
                git 'https://github.com/iheb137/OBP-API.git', branch: 'develop'
            }
        }
        stage('Clean and Build with Maven') {
            steps {
                echo '🧹 Nettoyage du cache Maven...'
                sh 'rm -rf ~/.m2/repository/com/tesobe/obp-*'
                
                echo '📦 Compilation avec Maven (force update)...'
                sh 'mvn -B clean install -DskipTests -U'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo '🏗️ Construction de l\'image Docker...'
                sh 'docker build -t iheb137/obp-api:latest .'
            }
        }
    }
    post {
        always {
            echo '✅ Pipeline terminée.'
        }
    }
}
