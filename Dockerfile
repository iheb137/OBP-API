# ÉTAPE 1: "Builder" - Compiler le code avec Maven
# Utilise une image Maven officielle pour construire l'application.
FROM maven:3.8.6-jdk-11 AS builder

# Définit le répertoire de travail à l'intérieur du conteneur.
WORKDIR /app

# Copie tout le code source du projet.
COPY . .

# Lance la compilation Maven.
# -DskipTests pour sauter les tests.
# -pl obp-api -am pour ne construire que le module api et ses dépendances.
# -P-ci pour désactiver les plugins problématiques en intégration continue.
RUN mvn -B clean package -DskipTests -pl obp-api -am -P-ci


# ÉTAPE 2: "Final" - Créer l'image de production avec Tomcat
# Utilise une image Tomcat officielle et corrigée avec Java 11.
FROM tomcat:9.0-jdk11-temurin

# Nettoie les applications par défaut de Tomcat pour ne garder que la nôtre.
RUN rm -rf /usr/local/tomcat/webapps/*

# Copie UNIQUEMENT le fichier .war depuis l'étape "builder" et le renomme en ROOT.war
# pour qu'il soit l'application par défaut de Tomcat.
COPY --from=builder /app/obp-api/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Copie UNIQUEMENT le fichier de configuration depuis l'étape "builder".
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props

# Définit les options Java pour l'application, y compris le chemin vers le fichier de configuration.
ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"

# Expose le port 8080 sur lequel Tomcat écoute.
EXPOSE 8080

# La commande pour démarrer le serveur Tomcat.
CMD ["catalina.sh", "run"]
