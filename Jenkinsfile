pipeline {
    agent {
        docker {
            image 'iheb99/maven-docker-kubectl:latest'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8 --network=host'
        }
    }

    environment {
        DOCKER_IMAGE = "iheb99/obp-api:latest"
        DOCKER_CREDENTIALS = "docker-hub-creds"
        // La variable KUBECONFIG_CREDENTIALS a été supprimée car nous utilisons une méthode plus sûre
        GIT_BRANCH = "develop"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/iheb137/OBP-API.git'
            }
        }

        stage('Build & Package') {
            steps {
                sh 'cp obp-api/src/main/resources/props/test.default.props.template obp-api/src/main/resources/props/test.default.props'
                withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                    sh 'mvn -B clean package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} -f obp-api/Dockerfile obp-api'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        // ======================================================================
        // === NOUVELLE ETAPE DE DEPLOIEMENT CORRIGEE ===
        // ======================================================================
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Loading Kubernetes config...'
                    // MODIFICATION : On charge le fichier kubeconfig secret
                    withCredentials([file(credentialsId: 'kubeconfig-portable', variable: 'KUBECONFIG_FILE')]) {
                        echo 'Deploying application to Kubernetes...'
                        // MODIFICATION : On dit à kubectl d'utiliser ce fichier spécifique
                        // ACTION REQUISE : Assurez-vous que le chemin vers votre fichier yaml est correct !
                        sh "env KUBECONFIG=$KUBECONFIG_FILE kubectl apply -f obp-api/deployment.yaml"
                    }
                    echo 'Deployment finished.'
                }
            }
        }
    }
}
