FROM tomcat:9.0-jdk11

# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file and rename it to ROOT.war
COPY obp-api/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Copy the configuration file from the source code into the application's classpath
COPY obp-api/src/main/resources/props/default.props /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/props/default.props

# Expose Tomcat's port
EXPOSE 8080

# Run Tomcat
CMD ["catalina.sh", "run"]
