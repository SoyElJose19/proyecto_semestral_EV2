🔒 Prácticas DevOps y Seguridad Aplicadas
Este proyecto cumple con los más altos estándares de desarrollo y despliegue:

Imágenes Multi-stage: Todos los Dockerfile utilizan etapas de compilación (builder) para generar artefactos, y luego los copian a imágenes base muy ligeras (alpine), reduciendo drásticamente el peso de la imagen final.
Mínimo Privilegio: Los contenedores en producción ejecutan los servicios bajo usuarios sin privilegios (appuser y appgroup), bloqueando la ejecución como root.
Infraestructura Inmutable: Todo el ecosistema de AWS es gestionado de forma declarativa mediante Terraform.
Security Groups (Firewalls): Reglas estrictas aplicadas; la base de datos solo acepta tráfico desde ECS, y los backends solo aceptan tráfico desde el ALB.



Cómo Desplegar el Proyecto (Guía de Uso)

1. Aprovisionar la Infraestructura

Configurar las credenciales de AWS CLI en su máquina local.

Navegar a la carpeta de infraestructura y ejecutar Terraform:

Bash
cd infra
terraform init
terraform apply -auto-approve
Copiar el alb_dns_name que retorna Terraform al finalizar.


2. Configurar el Pipeline CI/CD
En GitHub, configurar los Repository Secrets:

AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN.

Al realizar un git push a la rama de despliegue (deploy o develop), GitHub Actions automáticamente:
Compilará las imágenes de Docker.

Subirá las imágenes a los repositorios de AWS ECR.

Actualizará los servicios de AWS ECS forzando un nuevo despliegue.

3. Acceso a la Aplicación
Una vez que el pipeline finalice con éxito y los contenedores estén en estado RUNNING:
Abra su navegador web.
Ingrese la URL del balanceador de carga (ALB).

Ejemplo: http://proyecto-semestral-alb-XXXXX.us-east-1.elb.amazonaws.com

👥 Autores y Mantenimiento
Jose Espinosa
Vicente Garrido

Profesor: Alan Marcelo Gajardo Medina

Proyecto desarrollado para la asignatura de Introducción a Herramientas DevOps.
