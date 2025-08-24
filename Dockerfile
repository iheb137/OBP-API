# Stage 1: Build avec Maven
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
COPY . .
# Exécuter le build Maven pour générer le WAR
RUN mvn clean package -DskipTests -pl obp-api -am
# Créer le fichier default.props si nécessaire (au cas où il n'existe pas dans le repo)
RUN mkdir -p obp-api/src/main/resources/props && \
    echo "run.mode=production" > obp-api/src/main/resources/props/default.props && \
    echo "db.driver=org.postgresql.Driver" >> obp-api/src/main/resources/props/default.props && \
    echo "db.url=jdbc:postgresql://postgres-service:5432/postgres?sslmode=disable" >> obp-api/src/main/resources/props/default.props && \
    echo "db.user=postgres" >> obp-api/src/main/resources/props/default.props && \
    echo "db.password=postgres" >> obp-api/src/main/resources/props/default.props && \
    echo "connector=mapped" >> obp-api/src/main/resources/props/default.props && \
    echo "hostname=http://localhost:8080" >> obp-api/src/main/resources/props/default.props && \
    echo "allow_public_views=true" >> obp-api/src/main/resources/props/default.props && \
    echo "allow_sandbox_data_import=true" >> obp-api/src/main/resources/props/default.props && \
    echo "allow_sandbox_account_creation=true" >> obp-api/src/main/resources/props/default.props && \
    echo "allow_account_deletion=true" >> obp-api/src/main/resources/props/default.props && \
    echo "payments_enabled=false" >> obp-api/src/main/resources/props/default.props && \
    echo "importer_secret=change_me" >> obp-api/src/main/resources/props/default.props && \
    echo "sandbox_data_import_secret=change_me" >> obp-api/src/main/resources/props/default.props && \
    echo "server_mode=apis,portal" >> obp-api/src/main/resources/props/default.props && \
    echo "lift.base_url=http://localhost:8080" >> obp-api/src/main/resources/props/default.props && \
    echo "lift.context_path=/" >> obp-api/src/main/resources/props/default.props && \
    echo "log.level=INFO" >> obp-api/src/main/resources/props/default.props

# Stage 2: Runtime avec Tomcat
FROM tomcat:9.0-jdk11
# Nettoyer les applications par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*
# Copier le WAR généré depuis le stage builder
COPY --from=builder /app/obp-api/target/obp-api-1.10.1.war /usr/local/tomcat/webapps/ROOT.war
# Copier le fichier default.props dans le classpath de l'application
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props
# Définir JAVA_OPTS pour spécifier le chemin des props
ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"
# Exposer le port de Tomcat
EXPOSE 8080
# Lancer Tomcat
CMD ["catalina.sh", "run"]
