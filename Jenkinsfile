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

        stage('Configure Application for PostgreSQL') {
            steps {
                dir('obp-api') {
                    // Copie du template
                    sh 'cp src/main/resources/props/test.default.props.template src/main/resources/props/default.props'

                    // Modification pour utiliser PostgreSQL
                    sh '''
                        echo "" >> src/main/resources/props/default.props
                        echo "# --- PostgreSQL Settings ---" >> src/main/resources/props/default.props
                        echo "db.driver=org.postgresql.Driver" >> src/main/resources/props/default.props
                        echo "db.url=jdbc:postgresql://${OBP_API_DB_HOSTNAME}:${OBP_API_DB_PORT}/${OBP_API_DB_DATABASE}" >> src/main/resources/props/default.props
                        echo "db.user=${OBP_API_DB_USER}" >> src/main/resources/props/default.props
                        echo "db.password=${OBP_API_DB_PASSWORD}" >> src/main/resources/props/default.props
                    '''
                }
            }
        }

        stage('Build & Package') {
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
                        echo 'Building temporary kubeconfig file...'
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

                        echo "Deploying PostgreSQL Database..."
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-secret.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-pv.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-pvc.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-deployment.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f postgres-service.yaml"

                        echo "Deploying OBP-API Application..."
                        sh "kubectl --kubeconfig=${kubeconfig} apply -f deployment.yaml"

                        echo "Forcing deployment rollout to pick up the new image..."
                        sh "kubectl --kubeconfig=${kubeconfig} rollout restart deployment obp-api-deployment"

                        echo "Deployment successful."
                    }
                }
            }
        }
    }
}
