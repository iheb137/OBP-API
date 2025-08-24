# Stage 1: Build avec Maven
FROM maven:3.8.6-jdk-11 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -pl obp-api -am

# Stage 2: Runtime avec Tomcat
FROM tomcat:9.0-jdk11
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/obp-api/target/obp-api-1.10.1.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /app/obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props
ENV JAVA_OPTS="-Drun.mode=production -Dprops.path=/usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props"
EXPOSE 8080
CMD ["catalina.sh", "run"]
