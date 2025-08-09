# ========================================
# STAGE 1 : Compilation avec Maven + JDK 17
# ========================================
FROM maven:3-eclipse-temurin-17 AS builder

# Définir un répertoire de travail
WORKDIR /usr/src/obp-api

# Copier tout le code source
COPY . .

# Préparer les fichiers de configuration (obligatoires pour OBP)
RUN cp obp-api/src/main/resources/props/test.default.props.template obp-api/src/main/resources/props/test.default.props
RUN cp obp-api/src/main/resources/props/sample.props.template obp-api/src/main/resources/props/default.props

# Compiler et installer obp-commons d'abord (dépendance interne)
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B install -pl .,obp-commons -DskipTests

# Compiler obp-api (sans tests)
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B install -pl obp-api -DskipTests

# ========================================
# STAGE 2 : Image d'exécution légère avec Jetty + JDK 17
# ========================================
FROM jetty:9.4-jdk17-openjdk

# Nom de l'application
ENV APP_NAME=obp-api

# Copier le fichier .war depuis le stage de compilation
COPY --from=builder /usr/src/obp-api/obp-api/target/${APP_NAME}-*.war /var/lib/jetty/webapps/ROOT.war

# Exposer le port 8080
EXPOSE 8080

# Message de démarrage
RUN echo "✅ Image prête. L'application OBP-API démarrera sur http://localhost:8080"

# Pas besoin de CMD, Jetty est lancé par défaut
