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
                // Le fichier props.default est déjà dans Git, on n'a pas besoin de le créer ici.
                // On compile simplement l'application.
                withMaven(mavenSettingsConfig: 'obp-maven-settings') {
                    sh 'mvn -B clean package -DskipTests -pl obp-api -am'
                }
            }
        }
       
        stage('Build Docker Image') {
            steps {
                sh '''
                # Créer un Dockerfile optimisé pour OBP-API
                cat > Dockerfile <<EOL
FROM tomcat:9.0-jdk11

# Supprimer les applications par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR comme ROOT.war (application par défaut)
COPY obp-api/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war

# Créer le répertoire props et copier la configuration
RUN mkdir -p /props
COPY obp-api/src/main/resources/props/default.props /props/default.props

# Variables d'environnement pour OBP
ENV JAVA_OPTS="-Drun.mode=production -Dprops.resource=props.default"

# Exposer le port
EXPOSE 8080

# Démarrer Tomcat
CMD ["catalina.sh", "run"]
EOL
                '''
                
                sh "docker build --no-cache -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS ) {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            environment {
                K8S_CA_CERT_ID = 'k8s-ca-cert-b64'
                K8S_CLIENT_CERT_ID = 'k8s-client-cert-b64'
                K8S_CLIENT_KEY_ID = 'k8s-client-key-b64'
            }
            steps {
                withCredentials([
                    string(credentialsId: env.K8S_CA_CERT_ID, variable: 'K8S_CA_CERT'),
                    string(credentialsId: env.K8S_CLIENT_CERT_ID, variable: 'K8S_CLIENT_CERT'),
                    string(credentialsId: env.K8S_CLIENT_KEY_ID, variable: 'K8S_CLIENT_KEY')
                ]) {
                    script {
                        def kubeconfig = './kubeconfig_generated.yaml'
                        sh """
                            echo "apiVersion: v1" > ${kubeconfig}
                            echo "clusters:" >> ${kubeconfig}
                            echo "- cluster:" >> ${kubeconfig}
                            echo "    certificate-authority-data: \$K8S_CA_CERT" >> ${kubeconfig}
                            echo "    server: https://192.168.49.2:8443" >> ${kubeconfig}
                            echo "  name: minikube" >> ${kubeconfig}
                            echo "contexts:" >> ${kubeconfig}
                            echo "- context:" >> ${kubeconfig}
                            echo "    cluster: minikube" >> ${kubeconfig}
                            echo "    user: minikube" >> ${kubeconfig}
                            echo "  name: minikube" >> ${kubeconfig}
                            echo "current-context: minikube" >> ${kubeconfig}
                            echo "kind: Config" >> ${kubeconfig}
                            echo "preferences: {}" >> ${kubeconfig}
                            echo "users:" >> ${kubeconfig}
                            echo "- name: minikube" >> ${kubeconfig}
                            echo "  user:" >> ${kubeconfig}
                            echo "    client-certificate-data: \$K8S_CLIENT_CERT" >> ${kubeconfig}
                            echo "    client-key-data: \$K8S_CLIENT_KEY" >> ${kubeconfig}
                        """
                        
                        echo "Deploying to Kubernetes..."
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-secret.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-pv.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-pvc.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-deployment.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-service.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f deployment.yaml"
                        
                        echo "Deployment successful. Waiting for pods to be ready..."
                        sh "kubectl --kubeconfig=${kubeconfig} wait --for=condition=ready pod -l app=obp-api --timeout=300s"
                        
                        echo "Getting service URL..."
                        sh "kubectl --kubeconfig=${kubeconfig} get services"
                    }
                }
            }
        }
    }
}
// Force workspace refresh
