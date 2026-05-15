variable "aws_region" {
  description = "Region AWS"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  default     = "proyecto-semestral"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_publica_cidr" {
  description = "CIDR subred publica"
  default     = "10.0.1.0/24"
}

variable "subnet_privada_cidr" {
  description = "CIDR subred privada"
  default     = "10.0.2.0/24"
}

variable "ami_id" {
  description = "AMI Ubuntu 22.04"
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "Tipo de instancia"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key Pair SSH"
  default     = "vockey"
}