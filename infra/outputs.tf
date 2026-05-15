output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_despachos_url" {
  value = aws_ecr_repository.backend_despachos.repository_url
}

output "ecr_backend_ventas_url" {
  value = aws_ecr_repository.backend_ventas.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
