# ÉTAPE 1: "Builder" - Compiler le code avec Maven
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
COPY . .
# AJOUTEZ -P-ci ICI pour désactiver le plugin problématique
RUN mvn -B clean package -DskipTests -pl obp-api -am -P-ci

# ... le reste du Dockerfile ne change pas ...

# ÉTAPE 2: "Final" - Créer l'image Tomcat avec l'application
FROM tomcat:9.0-jdk-11
# ... etc ...
