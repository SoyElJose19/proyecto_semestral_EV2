output "cluster_endpoint" { 
  value = aws_eks_cluster.eks.endpoint 
}
output "ecr_front_url" { 
  value = aws_ecr_repository.repo_front.repository_url 
}