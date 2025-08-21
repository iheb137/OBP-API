FROM tomcat:9.0-jdk11-openjdk

RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR
COPY obp-api/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Copier la config props
COPY ./obp-api/src/main/resources/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props

EXPOSE 8080

CMD ["catalina.sh", "run"]
