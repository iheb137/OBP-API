# Stage 1: Build avec Maven
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
# Copier les fichiers POM pour télécharger les dépendances en premier
COPY pom.xml .
COPY obp-commons/pom.xml obp-commons/
COPY obp-api/pom.xml obp-api/
RUN mvn dependency:go-offline -B
# Copier le reste du code
COPY . .
# Créer default.props dans le conteneur si nécessaire
RUN mkdir -p obp-api/src/main/resources/props
RUN echo "# --- Run Mode ---" > obp-api/src/main/resources/props/default.props
RUN echo "run.mode=production" >> obp-api/src/main/resources/props/default.props
RUN echo "# --- Database Configuration ---" >> obp-api/src/main/resources/props/default.props
RUN echo "db.driver=org.postgresql.Driver" >> obp-api/src/main/resources/props/default.props
RUN echo "db.url=jdbc:postgresql://postgres-service:5432/postgres?sslmode=disable" >> obp-api/src/main/resources/props/default.props
RUN echo "db.user=postgres" >> obp-api/src/main/resources/props/default.props
RUN echo "db.password=postgres" >> obp-api/src/main/resources/props/default.props
RUN echo "# --- OBP Application Configuration ---" >> obp-api/src/main/resources/props/default.props
RUN echo "connector=mapped" >> obp-api/src/main/resources/props/default.props
RUN echo "hostname=http://localhost:8080" >> obp-api/src/main/resources/props/default.props
RUN echo "allow_public_views=true" >> obp-api/src/main/resources/props/default.props
RUN echo "allow_sandbox_data_import=true" >> obp-api/src/main/resources/props/default.props
RUN echo "allow_sandbox_account_creation=true" >> obp-api/src/main/resources/props/default.props
RUN echo "allow_account_deletion=true" >> obp-api/src/main/resources/props/default.props
RUN echo "payments_enabled=false" >> obp-api/src/main/resources/props/default.props
RUN echo "importer_secret=change_me" >> obp-api/src/main/resources/props/default.props
RUN echo "sandbox_data_import_secret=change_me" >> obp-api/src/main/resources/props/default.props
RUN echo "server_mode=apis,portal" >> obp-api/src/main/resources/props/default.props
RUN echo "# --- Lift Web Framework Configuration ---" >> obp-api/src/main/resources/props/default.props
RUN echo "lift.base_url=http://localhost:8080" >> obp-api/src/main/resources/props/default.props
RUN echo "lift.context_path=/" >> obp-api/src/main/resources/props/default.props
RUN echo "# --- Logging Configuration ---" >> obp-api/src/main/resources/props/default.props
RUN echo "log.level=INFO" >> obp-api/src/main/resources/props/default.props
RUN mvn clean package -DskipTests -pl obp-api -am

# Stage 2: Runtime avec Tomcat
FROM tomcat:9.0-jdk11
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/obp-api/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props
ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"
EXPOSE 8080
CMD ["catalina.sh", "run"]
