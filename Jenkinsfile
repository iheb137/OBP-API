pipeline {
    agent {
        // L'agent s'exécute sur le master Jenkins, qui a déjà accès à Docker.
        label 'master'
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                git branch: 'develop', credentialsId: 'github-token', url: 'https://github.com/iheb137/OBP-API.git'
            }
        }
        
        stage('Build, Push & Deploy') {
            agent {
                // On utilise votre image custom pour avoir kubectl et docker
                docker {
                    image 'iheb99/maven-docker-kubectl:latest'
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8'
                }
            }
            steps {
                script {
                    // 1. Construire l'image avec notre nouveau Dockerfile multi-étapes
                    def dockerImage = docker.build("iheb99/obp-api:latest", "--no-cache .")
                    
                    // 2. Pousser l'image vers Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-creds') {
                        dockerImage.push()
                    }
                }
                
                // 3. Déployer sur Kubernetes
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
                    }
                }
            }
        }
    }
}
