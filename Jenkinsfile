pipeline {
    agent {
        docker {
            image 'iheb99/maven-docker-kubectl:latest'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8 --network=host -v maven-cache:/root/.m2'
        }
    }

    options {
        timeout(time: 60, unit: 'MINUTES') // Augmenté à 60 min pour éviter timeout
    }

    environment {
        DOCKER_IMAGE       = "iheb99/obp-api:latest"
        DOCKER_CREDENTIALS = "docker-hub-creds"
        GIT_BRANCH         = "develop"
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
                    sh 'mvn -B clean package -DskipTests -pl obp-api -am -Pci' // Ajout -Pci pour skip git-commit-id-plugin
                }
            }
        }
       
        stage('Build & Push Docker Image') {
            steps {
                sh "docker build --no-cache -t ${DOCKER_IMAGE} ."
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(credentialsId: 'minikube-ca-cert', variable: 'K8S_CA_CERT_FILE'),
                    file(credentialsId: 'minikube-client-cert', variable: 'K8S_CLIENT_CERT_FILE'),
                    file(credentialsId: 'minikube-client-key', variable: 'K8S_CLIENT_KEY_FILE')
                ]) {
                    script {
                        def kubeconfig = './kubeconfig_generated.yaml'
                        sh """
                            kubectl config set-cluster minikube --server=https://192.168.49.2:8443 --certificate-authority=\$K8S_CA_CERT_FILE --embed-certs=true --kubeconfig=${kubeconfig}
                            kubectl config set-credentials minikube --client-certificate=\$K8S_CLIENT_CERT_FILE --client-key=\$K8S_CLIENT_KEY_FILE --embed-certs=true --kubeconfig=${kubeconfig}
                            kubectl config set-context minikube --cluster=minikube --user=minikube --kubeconfig=${kubeconfig}
                            kubectl config use-context minikube --kubeconfig=${kubeconfig}
                        """
                        
                        echo "Deploying to Kubernetes..."
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f ./k8s"
                        
                        echo "Waiting for pods to be ready..."
                        sh "kubectl --kubeconfig=${kubeconfig} wait --for=condition=ready pod -l app=obp-api --timeout=300s"
                        
                        echo "Getting service URL..."
                        sh "kubectl --kubeconfig=${kubeconfig} get svc obp-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
                    }
                }
            }
        }
    }
}
