FROM tomcat:9.0-jdk11

RUN rm -rf /usr/local/tomcat/webapps/*

COPY obp-api/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war
RUN mkdir -p /props
COPY obp-api/target/default.props /props/default.props

# Exposer le port de Tomcat
EXPOSE 8080

# Lancer Tomcat
CMD ["catalina.sh", "run"]
