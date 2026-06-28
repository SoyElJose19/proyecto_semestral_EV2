resource "aws_ecr_repository" "repo_front" {
  name = "frontend-despacho"
}
resource "aws_ecr_repository" "repo_back_despachos" {
  name = "backend-despachos"
}
resource "aws_ecr_repository" "repo_back_ventas" {
  name = "backend-ventas"
}
