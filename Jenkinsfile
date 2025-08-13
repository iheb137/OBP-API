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
                // On se place dans le sous-dossier obp-api (nom exact en minuscules)
                dir('obp-api') {
                    // CORRECTION : Utilisation du nom de fichier correct
                    sh 'cp src/main/resources/props/default.props.template src/main/resources/props/test.default.props'
                    withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                        sh 'mvn -B clean package -DskipTests'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Le Dockerfile est à la racine du workspace
                sh "docker build -t ${DOCKER_IMAGE} -f Dockerfile ."
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
                        echo 'Building temporary kubeconfig file...'
                        sh '''
                            echo "apiVersion: v1" > ./kubeconfig_generated.yaml
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
                        sh 'kubectl --kubeconfig=./kubeconfig_generated.yaml apply -f deployment.yaml'
                        
                        echo "Deployment successful."
                    }
                }
            }
        }
    }
}
