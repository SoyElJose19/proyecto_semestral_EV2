# Etapa 1: Construcción (Maven)
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Se saltan las pruebas para acelerar el despliegue
RUN mvn clean package -DskipTests

# Etapa 2: Producción (Java)
FROM openjdk:17-jdk-alpine
WORKDIR /app

# Creación de usuario no root para seguridad
RUN addgroup -S springgroup && adduser -S springuser -G springgroup
USER springuser:springgroup

COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]