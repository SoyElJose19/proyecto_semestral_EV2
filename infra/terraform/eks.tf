# infra/terraform/eks.tf

# 1. Definición del Cluster EKS
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    # Usamos las subredes de tu módulo VPC
    subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  }

  # Asegura que el cluster espere a que las dependencias de IAM estén listas
  depends_on = [data.aws_iam_role.labrole]
}

# 2. Definición del Grupo de Nodos (Workers)
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "devops-workers"
  node_role_arn   = data.aws_iam_role.labrole.arn
  
  # Despliegue en subredes privadas para mayor seguridad
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"] 
  capacity_type  = "ON_DEMAND"

  labels = {
    environment = "education"
  }

  depends_on = [aws_eks_cluster.eks]
}