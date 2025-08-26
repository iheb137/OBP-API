# Étape 1: Construire l'application avec Maven
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
COPY . .
RUN mvn -B clean package -DskipTests -pl obp-api -am -Pci

# Étape 2: Créer l'image finale avec Tomcat
FROM tomcat:9.0-jdk11
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR depuis l'étape "builder" et le renommer en ROOT.war
COPY --from=builder /app/obp-api/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Copier le fichier de configuration depuis l'étape "builder"
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props

ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"

EXPOSE 8080
CMD ["catalina.sh", "run"]
