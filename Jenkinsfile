pipeline {
    agent {
        docker {
            image 'iheb99/maven-docker-kubectl:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_IMAGE = "iheb99/obp-api:latest"
        DOCKER_CREDENTIALS = "docker-hub-creds"
        JIRA_CREDENTIALS = "jira-creds"
        KUBECONFIG_CREDENTIALS = "kubeconfig"
        GIT_BRANCH = "develop"
        JIRA_SITE = "https://saafiihebsi.atlassian.net"
        JIRA_ISSUE = "KAN-1"  // Remplace par la clé de ton ticket Jira
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${env.GIT_BRANCH}", url: 'https://github.com/iheb137/OBP-API.git'
            }
        }

        stage('Build') {
            steps {
                // MODIFICATION : Utilisation du fichier settings.xml personnalisé
                withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                    sh 'mvn -B clean package -DskipTests'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                // MODIFICATION : Utilisation du fichier settings.xml personnalisé
                withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                    sh 'mvn test'
                }
            }
        }

        stage('Code Quality') {
            steps {
                // MODIFICATION : Utilisation du fichier settings.xml personnalisé
                withMaven(mavenSettingsConfig: 'clean-maven-settings') {
                    // Adapter ou supprimer si pas SonarQube
                    sh 'mvn verify sonar:sonar -Dsonar.projectKey=obp-api -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_CREDENTIALS}") {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS}", variable: 'KUBECONFIG')]) {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }

        stage('Post-Deployment Tests') {
            steps {
                sh 'kubectl rollout status deployment/obp-api'
                sh 'curl -f http://obp-api-service:8080/health'
            }
        }

        stage('Update Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${JIRA_CREDENTIALS}", passwordVariable: 'JIRA_API_TOKEN', usernameVariable: 'JIRA_USER')]) {
                        sh """
                            curl -X POST -H 'Content-Type: application/json' \\
                            -u $JIRA_USER:$JIRA_API_TOKEN \\
                            --data '{"body":"✅ Build ${BUILD_NUMBER} déployé et testé avec succès."}' \\
                            ${JIRA_SITE}/rest/api/2/issue/${JIRA_ISSUE}/comment
                        """
                    }
                }
            }
        }
    }

    post {
        failure {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${JIRA_CREDENTIALS}", passwordVariable: 'JIRA_API_TOKEN', usernameVariable: 'JIRA_USER')]) {
                        sh """
                            curl -X POST -H 'Content-Type: application/json' \\
                            -u $JIRA_USER:$JIRA_API_TOKEN \\
                            --data '{"body":"❌ Build ${BUILD_NUMBER} a échoué."}' \\
                            ${JIRA_SITE}/rest/api/2/issue/${JIRA_ISSUE}/comment
                        """
                    }
                }
            }
        }
    }
}
