pipeline {
    agent {
        docker {
            image 'iheb99/maven-docker-kubectl:latest'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock --dns 8.8.8.8 --network=host -v maven-cache:/root/.m2'
        }
    }
    options {
        timeout(time: 20, unit: 'MINUTES') // Réduit après premier build réussi
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
                sh '''
                # Créer le fichier de configuration
                mkdir -p obp-api/src/main/resources/props
                cat > obp-api/src/main/resources/props/default.props <<EOL
# --- Run Mode ---
run.mode=production
# --- Database Configuration ---
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://postgres-service:5432/postgres?sslmode=disable
db.user=postgres
db.password=postgres
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
server_mode=apis,portal
# --- Lift Web Framework Configuration ---
lift.base_url=http://localhost:8080
lift.context_path=/
# --- Logging Configuration ---
log.level=INFO
EOL
                # Configurer settings.xml pour Maven
                mkdir -p ~/.m2
                cat > ~/.m2/settings.xml <<EOL
<settings>
    <mirrors>
        <mirror>
            <id>central</id>
            <name>Central Repository</name>
            <url>https://repo1.maven.org/maven2</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>jitpack</id>
            <repositories>
                <repository>
                    <id>jitpack.io</id>
                    <url>https://jitpack.io</url>
                </repository>
            </repositories>
        </profile>
    </profiles>
    <activeProfiles>
        <activeProfile>jitpack</activeProfile>
    </activeProfiles>
</settings>
EOL
                '''
                withMaven(mavenSettingsConfig: 'obp-maven-settings') {
                    sh 'mvn -B clean package -DskipTests -pl obp-api -am -Dmaven.repo.local=/root/.m2/repository'
                }
                sh '''
                # Vérifier et renommer le WAR
                if [ -f obp-api/target/obp-api-1.10.1.war ]; then
                    mv obp-api/target/obp-api-1.10.1.war obp-api/target/ROOT.war
                    echo "WAR renommé en ROOT.war avec succès."
                else
                    echo "Erreur : WAR file obp-api-1.10.1.war non trouvé !"
                    exit 1
                fi
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                # Vérifier les fichiers avant build
                if [ ! -f obp-api/src/main/resources/props/default.props ]; then
                    echo "Erreur : default.props non trouvé !"
                    exit 1
                fi
                if [ ! -f obp-api/target/ROOT.war ]; then
                    echo "Erreur : ROOT.war non trouvé après renommage !"
                    exit 1
                fi
                '''
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
            post {
                success {
                    echo "Image Docker ${DOCKER_IMAGE} construite avec succès."
                }
                failure {
                    echo "Échec du build Docker : Vérifiez les chemins des fichiers WAR et props."
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
                            kubectl --kubeconfig=${kubeconfig} apply -f postgres-secret.yaml
                            kubectl --kubeconfig=${kubeconfig} apply -f postgres-pv.yaml
                            kubectl --kubeconfig=${kubeconfig} apply -f postgres-pvc.yaml
                            kubectl --kubeconfig=${kubeconfig} apply -f postgres-deployment.yaml
                            kubectl --kubeconfig=${kubeconfig} apply -f postgres-service.yaml
                            kubectl --kubeconfig=${kubeconfig} apply -f deployment.yaml
                            echo "Deployment successful. Waiting for pods to be ready..."
                            kubectl --kubeconfig=${kubeconfig} wait --for=condition=ready pod -l app=obp-api --timeout=300s
                            echo "Getting service URL..."
                            kubectl --kubeconfig=${kubeconfig} get services
                        """
                    }
                }
            }
        }
    }
}
