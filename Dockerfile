# Stage 1: Copier les artefacts depuis l'étape Package Application
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
COPY . .
# Pas besoin de mvn dependency:go-offline, les dépendances sont déjà résolues

# Stage 2: Runtime avec Tomcat
FROM tomcat:9.0-jdk11
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/obp-api/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props
ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"
EXPOSE 8080
CMD ["catalina.sh", "run"]
