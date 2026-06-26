# Etapa 1: Compilación (Multi-stage build)
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copiar solo el pom.xml para aprovechar la caché de capas de Docker
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiar el código fuente
COPY src ./src

# Compilar sin tests para evitar errores de dependencias de test en el contenedor
RUN mvn clean package -Dmaven.test.skip=true

# Etapa 2: Ejecución (Imagen ligera)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Crear usuario no root por seguridad (Requisito IE1 de la pauta)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copiar el artefacto compilado desde la etapa builder
COPY --from=builder /app/target/*.jar app.jar

# Exponer el puerto configurado
EXPOSE 8080

# Comando de inicio
ENTRYPOINT ["java", "-jar", "app.jar"]