# Etapa de build
FROM maven:3-eclipse-temurin-21 AS builder
WORKDIR /app
COPY . .
RUN mvn -q -DskipTests clean package

# Etapa de run
FROM tomcat:10.1-jdk21-temurin
COPY --from=builder /app/target/LabPDAWeb-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/lab2PDA.war

#¿Qué es /usr/local/tomcat/? -> Es la carpeta de Tomcat dentro del contenedor (ruta Linux).
#Dentro está:
 #
 #bin/ (scripts de arranque)
 #
 #conf/ (config: server.xml, web.xml, etc.)
 #
 #webapps/ ⟵ acá van las apps
 #¿Por qué webapps/?
   #
   #Tomcat arranca y despliega automáticamente to do lo que encuentre en:
   #
   #webapps/*.war (archivos WAR)
   #
   #webapps/<carpeta> (apps ya “explosionadas”)