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
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/iheb137/OBP-API.git'
            }
        }

        stage('Build & Package') {
            steps {
                // Le cd est nécessaire car le git clone crée un sous-dossier OBP-API
                dir('OBP-API') {
                    sh 'cp src/main/resources/props/test.default.props.template src/main/resources/props/test.default.props'
                    withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                        sh 'mvn -B clean package -DskipTests'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // On se place dans le dossier contenant le Dockerfile avant de build
                dir('OBP-API') {
                    sh "docker build -t ${DOCKER_IMAGE} -f Dockerfile ."
                }
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
        // === ETAPE DE DEPLOIEMENT FINALE, FIABLE ET FONCTIONNELLE ===
        // ======================================================================
        stage('Deploy to Kubernetes') {
            environment {
                // On définit les IDs des 3 secrets de type "Secret text"
                K8S_CA_CERT_ID = 'k8s-ca-cert-b64'
                K8S_CLIENT_CERT_ID = 'k8s-client-cert-b64'
                K8S_CLIENT_KEY_ID = 'k8s-client-key-b64'
            }
            steps {
                // On charge les 3 secrets dans des variables
                withCredentials([
                    string(credentialsId: env.K8S_CA_CERT_ID, variable: 'K8S_CA_CERT'),
                    string(credentialsId: env.K8S_CLIENT_CERT_ID, variable: 'K8S_CLIENT_CERT'),
                    string(credentialsId: env.K8S_CLIENT_KEY_ID, variable: 'K8S_CLIENT_KEY')
                ]) {
                    script {
                        echo 'Building temporary kubeconfig file...'
                        
                        // Création du fichier de configuration 100% fiable via des commandes echo
                        sh '''
                            # On crée le fichier avec la première ligne (>)
                            echo "apiVersion: v1" > ./kubeconfig_generated.yaml

                            # On ajoute les lignes suivantes (>>)
                            echo "clusters:" >> ./kubeconfig_generated.yaml
                            echo "- cluster:" >> ./kubeconfig_generated.yaml
                            echo "    certificate-authority-data: $K8S_CA_CERT" >> ./kubeconfig_generated.yaml
                            echo "    server: https://192.168.49.2:8443" >> ./kubeconfig_generated.yaml
                            echo "  name: minikube" >> ./kubeconfig_generated.yaml
                            echo "contexts:" >> ./kubeconfig_generated.yaml
                            echo "- context:" >> ./kubeconfig_generated.yaml
                            echo "    cluster: minikube" >> ./kubeconfig_generated.yaml
                            echo "    user: minikube" >> ./kubeconfig_generated.yaml
                            echo "  name: minikube" >> ./kubeconfig_generated.yaml
                            echo "current-context: minikube" >> ./kubeconfig_generated.yaml
                            echo "kind: Config" >> ./kubeconfig_generated.yaml
                            echo "preferences: {}" >> ./kubeconfig_generated.yaml
                            echo "users:" >> ./kubeconfig_generated.yaml
                            echo "- name: minikube" >> ./kubeconfig_generated.yaml
                            echo "  user:" >> ./kubeconfig_generated.yaml
                            echo "    client-certificate-data: $K8S_CLIENT_CERT" >> ./kubeconfig_generated.yaml
                            echo "    client-key-data: $K8S_CLIENT_KEY" >> ./kubeconfig_generated.yaml
                        '''
                        
                        echo "Deploying application to Kubernetes..."
                        
                        // On utilise le fichier qu'on vient de créer pour le déploiement
                        // ACTION REQUISE : Assurez-vous que ce chemin est correct !
                        sh 'kubectl --kubeconfig=./kubeconfig_generated.yaml apply -f OBP-API/deployment.yaml'
                        
                        echo "Deployment successful."
                    }
                }
            }
        }
    }
}
