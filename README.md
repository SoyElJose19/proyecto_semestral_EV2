Proyecto Semestral: Sistema de Gestión de Ventas y Despachos (DevOps & EKS)
📋 Descripción del Proyecto
Este proyecto implementa una arquitectura de microservicios distribuida en AWS EKS, integrando el backend (Spring Boot), frontend (React) y persistencia (MySQL). La solución se basa en principios DevOps, logrando una infraestructura inmutable y un despliegue totalmente automatizado.

🏗️ Arquitectura del Sistema
El despliegue se basa en una VPC con subredes privadas y públicas, garantizando que los microservicios residan en una red aislada, expuestos únicamente a través de un LoadBalancer configurado en Kubernetes.

(Aquí se ilustra el flujo desde el CI/CD hasta la orquestación en el clúster EKS)

🛠️ Desafíos Técnicos Resueltos
Durante el desarrollo se superaron hitos críticos que garantizan la estabilidad del sistema:

Resolución de IAM (Error 403): Se omitió el uso del módulo aws_iam_session_context para evitar restricciones de denegación explícita en AWS Academy, optando por el uso de recursos directos (aws_eks_cluster).

Gestión del ciclo de vida ECR: Implementación de force_delete = true en los repositorios de imágenes para asegurar la limpieza total durante el proceso de terraform destroy.

Inicialización de Base de Datos: Uso de init.sql para el despliegue automático del esquema de MySQL, asegurando que el backend cuente con la estructura necesaria desde el primer arranque.

🚀 Guía de Despliegue
1. Infraestructura como Código (Terraform)
Gestión de la infraestructura desde infra/terraform/:

Bash
cd infra/terraform
terraform init
terraform plan
terraform apply -auto-approve
2. Orquestación (Kubernetes)
Configuración del contexto del clúster y despliegue de servicios:

Bash
# Conectar localmente al clúster recién creado
aws eks update-kubeconfig --region us-east-1 --name devops-proyect-cluster

# Desplegar manifiestos de microservicios
kubectl apply -f infra/k8s/
3. Ciclo de CI/CD (Pipeline)
El pipeline automatizado en GitHub Actions (.github/workflows/cd.yml) realiza:

Build: Compilación de microservicios.

Push: Construcción de imágenes Docker y subida a ECR.

Deploy: Aplicación de despliegues en el clúster EKS.

📊 Métricas de Rendimiento (Evaluación Transversal)
Tiempo de despliegue (Pipeline): ~5 minutos (optimizado mediante caché de capas en Docker).

Autoescalado: Implementado mediante HPA, permitiendo una respuesta de escalado ante picos de carga en menos de 90 segundos.

Disponibilidad: Alta disponibilidad asegurada mediante el despliegue multi-zona en EKS.

🧹 Limpieza (Destrucción)
Para liberar los recursos en AWS de forma limpia y evitar bloqueos:

Bash
# 1. Eliminar objetos de Kubernetes
kubectl delete -f infra/k8s/

# 2. Destruir infraestructura de Terraform
cd infra/terraform
terraform destroy -auto-approve
Autores: Jose Espinosa | Vicente Garrido
Asignatura: Proyecto de DevOps | Duoc UC
