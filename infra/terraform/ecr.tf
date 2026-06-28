resource "aws_ecr_repository" "repo_front" {
  name         = "frontend-despacho"
  force_delete = true
}
resource "aws_ecr_repository" "repo_back_despachos" {
  name         = "backend-despachos"
  force_delete = true
}
resource "aws_ecr_repository" "repo_back_ventas" {
  name         = "backend-ventas"
  force_delete = true
}