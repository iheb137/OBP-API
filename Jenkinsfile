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
        GIT_BRANCH = "develop"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/iheb137/OBP-API.git'
            }
        }

        stage('Package Application') {
            steps {
                withMaven(mavenSettingsConfig: 'obp-maven-settings') {
                    sh 'mvn -B clean package -DskipTests -pl obp-api -am'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build --no-cache -t ${DOCKER_IMAGE} -f Dockerfile ."
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
                script {
                    echo "Déploiement sur Kubernetes avec le contexte minikube..."
                    sh "kubectl config use-context minikube"
                    
                    // appliquer les manifests
                    sh "kubectl apply -f postgres-secret.yaml"
                    sh "kubectl apply -f postgres-pv.yaml"
                    sh "kubectl apply -f postgres-pvc.yaml"
                    sh "kubectl apply -f postgres-deployment.yaml"
                    sh "kubectl apply -f postgres-service.yaml"
                    sh "kubectl apply -f obp-api-configmap.yaml"
                    sh "kubectl apply -f deployment.yaml"

                    echo "✅ Déploiement terminé avec succès."
                }
            }
        }
    }
}
