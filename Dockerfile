# ÉTAPE 1: "Builder" - Compiler le code avec Maven
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
COPY . .
# La correction est ici : -Dgit.commit.id.skip=true désactive le plugin
RUN mvn -B clean package -DskipTests -pl obp-api -am -Dgit.commit.id.skip=true

# ÉTAPE 2: "Final" - Créer l'image de production avec Tomcat
FROM tomcat:9.0-jdk11-temurin
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR et la configuration depuis l'étape "builder"
COPY --from=builder /app/obp-api/target/*.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props

ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"
EXPOSE 8080
CMD ["catalina.sh", "run"]
