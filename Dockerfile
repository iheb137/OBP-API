# Étape 1 : Utiliser une image officielle de Tomcat avec Java 11 comme base
FROM tomcat:9.0-jdk11-openjdk

# Étape 2 : Nettoyer le dossier des applications de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Étape 3 : Copier le fichier .war de votre application (construit par Maven)
# et le renommer en ROOT.war pour qu'il soit le site par défaut.
COPY ./obp-api/target/obp-api-1.10.1.war /usr/local/tomcat/webapps/ROOT.war

# Étape 4 : Exposer le port par défaut de Tomcat pour qu'il soit accessible
EXPOSE 8080
