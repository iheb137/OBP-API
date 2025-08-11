pipeline {
    agent {
        docker {
            image 'iheb99/maven-docker-kubectl:latest'
            // MODIFICATION FINALE : Forcer l'exécution en tant qu'utilisateur root
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8'
        }
    }

    environment {
        DOCKER_IMAGE = "iheb99/obp-api:latest"
        DOCKER_CREDENTIALS = "docker-hub-creds"
        JIRA_CREDENTIALS = "jira-creds"
        KUBECONFIG_CREDENTIALS = "kubeconfig"
        GIT_BRANCH = "develop"
        JIRA_SITE = "https://saafiihebsi.atlassian.net"
        JIRA_ISSUE = "KAN-1"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/iheb137/OBP-API.git'
            }
        }

        stage('Build & Package') {
            steps {
                // Créer le fichier de configuration nécessaire pour la compilation des tests
                sh 'cp obp-api/src/main/resources/props/test.default.props.template obp-api/src/main/resources/props/test.default.props'
                
                withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                    // Nous compilons tout mais nous sautons l'exécution des tests
                    sh 'mvn -B clean package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_CREDENTIALS}") {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS}", variable: 'KUBECONFIG')]) {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }
    }
}
