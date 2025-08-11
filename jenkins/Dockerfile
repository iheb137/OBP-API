FROM jenkins/jenkins:lts

USER root

# Installation de Docker CLI
RUN apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce-cli

# Installation de kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Installation de Maven
RUN apt-get -y install maven

# Installation des plugins Jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Configuration initiale de Jenkins
COPY jenkins.yaml /var/jenkins_home/jenkins.yaml
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml

USER jenkins