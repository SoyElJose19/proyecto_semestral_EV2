output "frontend_public_ip" {
  description = "IP publica del Frontend"
  value       = aws_eip.frontend.public_ip
}

output "backend_private_ip" {
  description = "IP privada del Backend"
  value       = aws_instance.backend.private_ip
}

output "ssh_command" {
  description = "Comando para conectar por SSH"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.frontend.public_ip}"
}