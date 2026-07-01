Markdown
# Sistema de Gestión de Ventas y Despachos (DevOps CI/CD)

Proyecto final para la asignatura Introducción a Herramientas DevOps. Implementación de una arquitectura de microservicios automatizada en AWS, utilizando Infraestructura como Código (IaC) y un pipeline CI/CD completo.

## 1. Arquitectura del Sistema
El despliegue separa la lógica de negocio en subredes privadas, exponiendo únicamente el Frontend a través de un balanceador de carga público para garantizar la seguridad.

![Diagrama de Arquitectura Final](DiagramaTecnico.drawio.png)

## 2. Tecnologías Utilizadas
* **Contenedores:** Docker (Dockerfiles multietapa, Alpine).
* **CI/CD:** GitHub Actions.
* **Infraestructura Cloud:** AWS (VPC, ECR, LoadBalancers, Orquestación de contenedores).
* **Seguridad:** Trivy (Escaneo de vulnerabilidades).
* **Aplicaciones:** Spring Boot (Backends), React (Frontend), MySQL (Base de datos).

## 3. Entorno de Desarrollo Local (Levantamiento)
Para levantar el proyecto en un entorno de desarrollo local, utilizamos `docker-compose`. Este orquesta las redes internas y volúmenes necesarios.


# Construir imágenes y levantar contenedores en segundo plano
docker-compose up -d --build

# Verificar el estado de los servicios
docker-compose ps

## 4. Pipeline CI/CD (Testing, Build, Deploy)
El ciclo de vida de la aplicación está 100% automatizado mediante GitHub Actions. Al realizar un push a la rama de despliegue, el pipeline ejecuta:

Testing de Infraestructura/Seguridad: Escaneo de las imágenes generadas utilizando Trivy para detectar vulnerabilidades Críticas/Altas.

Build: Compilación del código (Maven/Node) y construcción de las imágenes Docker.

Push: Almacenamiento seguro de las imágenes en Amazon ECR.

Deploy: Actualización automática de los servicios en la nube de AWS, aplicando estrategias de rolling update para cero tiempo de inactividad.

## 5. Autores
Jose Espinosa

Vicente Garrido