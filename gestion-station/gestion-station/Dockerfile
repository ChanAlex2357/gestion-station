# Utiliser une image Alpine Linux comme base
FROM alpine:latest

# Installer OpenJDK 8 et autres dépendances
RUN apk update && apk add --no-cache \
    openjdk8-jre \
    wget \
    unzip

# Définir JAVA_HOME pour OpenJDK 8
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $JAVA_HOME/bin:$PATH

# Télécharger et installer WildFly
RUN wget https://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip \
    && unzip wildfly-10.1.0.Final.zip -d /opt/ \
    && mv /opt/wildfly-10.1.0.Final /opt/wildfly \
    && rm wildfly-10.1.0.Final.zip

# Définir WILDFLY_HOME
ENV WILDFLY_HOME /opt/wildfly

# Copier votre application WAR dans le dossier de déploiement de WildFly
COPY ./deployments/station.war $WILDFLY_HOME/standalone/deployments/station.war

RUN touch $WILDFLY_HOME/standalone/deployments/station.war.dodeploy

# Exposer les ports nécessaires
EXPOSE 8080 9990

# Démarrer WildFly
CMD ["/opt/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
