variable "aws_region" {
  default = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = "123456789012"  # ← Cambiar por el real
}

variable "project_name" {
  default = "devops"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_publica_cidr" {
  default = "10.0.1.0/24"
}

variable "db_name" {
  default = "despachos_ventas_db"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default     = "SecurePassword123!"
  sensitive   = true
}
