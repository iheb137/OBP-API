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

        stage('Package Application') {
            steps {
                // Créer un fichier de configuration complet avec les bonnes informations de base de données
                // et les autres paramètres par défaut nécessaires.
                sh '''
                cat > obp-api/src/main/resources/props/default.props <<EOL
# --- Database Configuration ---
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://postgres-service:5432/postgres?sslmode=disable
db.user=postgres
db.password=postgres_password

# --- OBP Application Configuration ---
connector=mapped
hostname=http://localhost:8080
allow_public_views=true
allow_sandbox_data_import=true
allow_sandbox_account_creation=true
allow_account_deletion=true
payments_enabled=false
importer_secret=change_me
sandbox_data_import_secret=change_me

# --- Default values from template ---
FREE_FORM_OTP_INSTRUCTION_TRANSPORT=dummy
SEPA_OTP_INSTRUCTION_TRANSPORT=dummy
SEPA_CREDIT_TRANSFERS_OTP_INSTRUCTION_TRANSPORT=dummy
CARD_OTP_INSTRUCTION_TRANSPORT=dummy
AGENT_CASH_WITHDRAWAL_OTP_INSTRUCTION_TRANSPORT=dummy
COUNTERPARTY_OTP_INSTRUCTION_TRANSPORT=dummy
ACCOUNT_OTP_INSTRUCTION_TRANSPORT=dummy
SIMPLE_OTP_INSTRUCTION_TRANSPORT=dummy
transactionRequests_supported_types=SANDBOX_TAN,COUNTERPARTY,SEPA,ACCOUNT_OTP,ACCOUNT,SIMPLE,AGENT_CASH_WITHDRAWAL,CARD
starConnector_supported_types=mapped,internal
messageQueue.createBankAccounts=false
messageQueue.updateBankAccountsTransaction=false
EOL
                '''
                
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
                        // Création du Kubeconfig avec la bonne adresse IP et le bon port
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
                        
                        echo "Deploying All Resources..."
                        sh "kubectl --kubeconfig=${kubeconfig} apply --validate=false -f postgres-secret.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply --validate=false -f postgres-pv.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply --validate=false -f postgres-pvc.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply --validate=false -f postgres-deployment.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply --validate=false -f postgres-service.yaml"
                        sh "kubectl --kubeconfig=${kubeconfig} apply --validate=false -f deployment.yaml"
                        
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
