output "database_public_ip" {
  description = "IP publica de la base de datos"
  value       = aws_eip.database.public_ip
}

output "ecr_frontend_url" {
  description = "URL del repositorio ECR Frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_despachos_url" {
  description = "URL del repositorio ECR Backend Despachos"
  value       = aws_ecr_repository.backend_despachos.repository_url
}

output "ecr_backend_ventas_url" {
  description = "URL del repositorio ECR Backend Ventas"
  value       = aws_ecr_repository.backend_ventas.repository_url
}

output "ssh_command" {
  description = "Comando para conectar por SSH"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.database.public_ip}"
}