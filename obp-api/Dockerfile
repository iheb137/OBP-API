# Étape 1: Utiliser une image de base avec un environnement d'exécution Java et un serveur d'application Tomcat
FROM tomcat:9.0-jdk11-temurin

# Étape 2: Supprimer les applications par défaut de Tomcat pour faire de la place
RUN rm -rf /usr/local/tomcat/webapps/*

# Étape 3: Copier votre fichier .war (construit par Maven) dans le dossier webapps de Tomcat.
# Le fichier est renommé en ROOT.war pour que l'application soit accessible à la racine de l'URL.
COPY target/obp-api-1.10.1.war /usr/local/tomcat/webapps/ROOT.war

# Étape 4: Exposer le port sur lequel Tomcat écoute
EXPOSE 8080

# Étape 5: Commande pour démarrer le serveur Tomcat lorsque le conteneur est lancé
CMD ["catalina.sh", "run"]
