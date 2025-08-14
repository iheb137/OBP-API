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
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/iheb137/OBP-API.git'
            }
        }

        stage('Build & Package') {
            steps {
                // Création du fichier de props standard
                dir('obp-api') {
                    sh 'cp src/main/resources/props/test.default.props.template src/main/resources/props/default.props'
                }
                
                withMaven(mavenSettingsConfig: 'obp-maven-settings') {
                    sh 'mvn -B clean package -DskipTests -pl obp-api -am -P pass-through-lift'
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

        stage('Deploy All to Kubernetes') {
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
                        // Création du Kubeconfig
                        sh """
                            echo "apiVersion: v1" > ${kubeconfig}
                            # ... (contenu du kubeconfig comme avant) ...
                        """
                        
                        echo "Deploying All Resources..."
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-secret.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-pv.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-pvc.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-deployment.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-service.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f deployment.yaml"
                        
                        echo "Forcing deployment rollouts..."
                        sh "kubectl --kubeconfig=${kubeconfig} rollout restart deployment postgres-deployment"
                        sh "kubectl --kubeconfig=${kubeconfig} rollout restart deployment obp-api-deployment"
                        
                        echo "Deployment successful."
                    }
                }
            }
        }
    }
}
