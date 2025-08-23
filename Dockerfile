FROM tomcat:9.0-jdk11

# Nettoyer les applications par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le fichier .war (produit par Maven) et le renommer en ROOT.war
COPY obp-api/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Copier le fichier de configuration depuis le code source vers le classpath de l'application
COPY obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props

# Exposer le port de Tomcat
EXPOSE 8080

# Lancer Tomcat
CMD ["catalina.sh", "run"]
