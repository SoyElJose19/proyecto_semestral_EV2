Markdown
# Sistema de Gestión de Ventas y Despachos: Arquitectura de Microservicios

[![AWS EKS](https://img.shields.io/badge/Amazon_AWS-EKS-FF9900?logo=amazonaws&logoColor=white)](#)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Orquestación-326CE5?logo=kubernetes&logoColor=white)](#)
[![Java](https://img.shields.io/badge/Java-Backend-ED8B00?logo=openjdk&logoColor=white)](#)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-Microservicios-6DB33F?logo=spring&logoColor=white)](#)
[![React](https://img.shields.io/badge/React-Frontend-61DAFB?logo=react&logoColor=black)](#)
[![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white)](#)

## 📋 Descripción del Proyecto
Proyecto semestral enfocado en la implementación de una arquitectura de microservicios distribuida en AWS. El sistema gestiona de forma desacoplada la lógica de negocio de **Ventas** y **Despachos**, integrando persistencia relacional en MySQL y un frontend interactivo, todo orquestado bajo Kubernetes (EKS).

La solución destaca por su alta disponibilidad, gestión de dependencias entre servicios mediante *InitContainers* y seguridad basada en el patrón de servicios privados (*ClusterIP*).

---

## 🛠 Arquitectura Tecnológica
* **Orquestación:** Amazon EKS (Kubernetes).
* **Backend:** Microservicios independientes en Java Spring Boot (`backend-ventas`, `backend-despacho`).
* **Frontend:** Aplicación SPA desarrollada con React.
* **Base de Datos:** MySQL desplegado con volúmenes persistentes.
* **Infraestructura:** Despliegue gestionado mediante archivos declarativos de Kubernetes.

---

## 🚀 Guía de Despliegue

### 1. Configuración del Contexto
Asegúrese de tener configurado el acceso a su clúster de AWS EKS:
```bash
aws eks update-kubeconfig --region us-east-1 --name <nombre-de-tu-cluster>
2. Despliegue de Recursos
Despliegue el ecosistema completo desde la carpeta raíz de infraestructura:

Bash
# Aplica todas las configuraciones (Pods, Services, Deployments)
kubectl apply -f infra/k8s/
Nota: La configuración incluye initContainers que garantizan que el backend espere a que MySQL esté listo antes de arrancar.

🔍 Comandos de Operación y Monitoreo
Utilice los siguientes comandos para gestionar el ciclo de vida de los microservicios:

Verificación de Estado
Bash
# Listar todos los pods y verificar que estén en estado 'Running'
kubectl get pods

# Ver detalles de un pod específico si presenta error
kubectl describe pod <nombre-del-pod>
Logs y Debugging
Bash
# Ver logs en tiempo real
kubectl logs -f <nombre-del-pod>

# Diagnóstico de red interno (ejecutar dentro del cluster)
kubectl run debug-pod --rm -it --image=busybox -- sh
# (Una vez dentro): wget -qO- http://backend-ventas:8082/
Acceso y Pruebas
Bash
# Crear túnel temporal para acceso al frontend desde local
kubectl port-forward svc/frontend-despacho 3000:80
💡 Notas de Implementación
Base de Datos: El sistema utiliza db_ventas y db_despachos. Se ha verificado la correcta inyección de variables de entorno (JDBC) para asegurar la persistencia.

Seguridad: Los servicios de Backend están configurados como ClusterIP para prevenir el acceso público directo, delegando el tráfico a través del frontend o mediante túneles de desarrollo.

👤 Autores
Jose Eduardo Espinosa Tapia
Vicente Garrido
Estudiantes Ingenieria en Informatica Duoc UC
***
