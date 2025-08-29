pipeline {
    // Utilise n'importe quel agent disponible pour la première étape (le checkout)
    agent any

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                // Checkout du code en utilisant votre token GitHub
                git branch: 'develop', credentialsId: 'github-token', url: 'https://github.com/iheb137/OBP-API.git'
            }
        }
        
        stage('Build, Push & Deploy') {
            // Utilise votre image Docker custom pour avoir accès à 'docker' et 'kubectl'
            agent {
                docker {
                    image 'iheb99/maven-docker-kubectl:latest'
                    // --network=host est la correction cruciale pour que kubectl puisse joindre Minikube
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8 --network=host'
                }
            }
            steps {
                // 1. Construire l'image avec le Dockerfile multi-étapes
                script {
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
                            # Créer un kubeconfig propre et fiable à partir des certificats
                            kubectl config set-cluster minikube --server=https://192.168.49.2:8443 --certificate-authority=\$K8S_CA_CERT_FILE --embed-certs=true --kubeconfig=${kubeconfig}
                            kubectl config set-credentials minikube --client-certificate=\$K8S_CLIENT_CERT_FILE --client-key=\$K8S_CLIENT_KEY_FILE --embed-certs=true --kubeconfig=${kubeconfig}
                            kubectl config set-context minikube --cluster=minikube --user=minikube --kubeconfig=${kubeconfig}
                            kubectl config use-context minikube --kubeconfig=${kubeconfig}
                        """
                        
                        echo "Deploying to Kubernetes..."
                        // Applique tous les fichiers de configuration du dossier k8s
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f ./k8s"
                        
                        echo "Deployment successful. Waiting for pods to be ready..."
                        sh "kubectl --kubeconfig=${kubeconfig} wait --for=condition=ready pod -l app=obp-api --timeout=300s"
                        
                        echo "Getting service URL..."
                        // Affiche l'URL et la liste des services à la fin du build
                        sh "echo '--> Application URL: http://192.168.49.2:'\$(kubectl --kubeconfig=${kubeconfig} get service obp-api-service -o jsonpath='{.spec.ports[0].nodePort}')"
                    }
                }
            }
        }
    }
}
