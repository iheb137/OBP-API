pipeline {
    agent any
    tools {
        maven 'Maven-3.9.6'
    }
    stages {
        stage('Checkout') {
            steps {
                echo '🔍 Checkout du code depuis GitHub...'
                git 'https://github.com/iheb137/OBP-API.git', branch: 'develop'
            }
        }
        stage('Package Application') {
            steps {
                echo '📦 Compilation et empaquetage avec Maven...'
                sh 'mvn -B clean package -DskipTests'
            }
        }
        stage('Run Unit Tests') {
            steps {
                echo '🧪 Exécution des tests unitaires...'
                // Créer le fichier de config pour les tests
                writeFile file: 'obp-api/src/test/resources/props/test.props',
                        text: '''hostname=http://127.0.0.1:8080
db.driver=org.h2.Driver
db.url=jdbc:h2:mem:OBPTest;DB_CLOSE_DELAY=-1'''
                sh 'mvn test'
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
        success {
            echo '✅ Pipeline terminée avec succès ! Image Docker créée.'
        }
        failure {
            echo '❌ La pipeline a échoué. Vérifie la console.'
        }
    }
}
