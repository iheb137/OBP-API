pipeline {
    agent any

    tools {
        // Ce nom correspond à ce que vous avez configuré
        maven 'Maven-3.9.6' 
    }

    stages {
        // ... le reste des étapes ...
        stage('Build with Maven') {
            steps {
                echo 'Building the project with Maven...'
                sh 'mvn -B clean install -DskipTests'
            }
        }
        // ...
    }
}

