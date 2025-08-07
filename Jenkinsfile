pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out from Git...'
            }
        }

        stage('Build with Maven') {
            steps {
                echo 'Building the project with Maven...'
                sh 'mvn -B clean install -DskipTests'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
