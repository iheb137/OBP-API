pipeline {
    agent {
        docker {
            image 'iheb99/maven-docker-kubectl:latest'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8'
        }
    }

    environment {
        DOCKER_IMAGE = "iheb99/obp-api:latest"
        DOCKER_CREDENTIALS = "docker-hub-creds"
        KUBECONFIG_CREDENTIALS = "kubeconfig"
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
                // CORRECTION : Le chemin doit inclure le sous-module 'obp-api' pour trouver les bons fichiers.
                sh 'cp obp-api/src/main/resources/props/test.default.props.template obp-api/src/main/resources/props/test.default.props'

                withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                    sh 'mvn -B clean package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // CORRECTION MAJEURE : On utilise le bon Dockerfile pour construire l'image de l'application.
                // Assurez-vous d'avoir bien créé le fichier 'obp-api/Dockerfile' comme expliqué précédemment.
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

        stage('Deploy to Kubernetes') {
            steps {
                // Utilisation du credential Kubeconfig pour se connecter au cluster.
                withCredentials([file(credentialsId: env.KUBECONFIG_CREDENTIALS, variable: 'KUBE_CONFIG')]) {
                    sh '''
                        export KUBECONFIG=$KUBE_CONFIG
                        kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }
    }
}
