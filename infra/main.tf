provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "devops-vpc" }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "devops-subnet-publica" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "devops-igw" }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}

# Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "devops-sg-ecs"
  description = "Security group for ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECR
resource "aws_ecr_repository" "frontend" { name = "devops-frontend" }
resource "aws_ecr_repository" "backend_despachos" { name = "devops-backend-despachos" }
resource "aws_ecr_repository" "backend_ventas" { name = "devops-backend-ventas" }

# ECS Cluster
resource "aws_ecs_cluster" "main" { name = "devops-cluster" }

# Task Definition Frontend
resource "aws_ecs_task_definition" "frontend" {
  family                   = "devops-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn
  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.frontend.repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 80, hostPort = 80 }]
  }])
}

# Task Definition Backend Despachos
resource "aws_ecs_task_definition" "backend_despachos" {
  family                   = "devops-backend-despachos"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn
  container_definitions = jsonencode([{
    name      = "backend-despachos"
    image     = "${aws_ecr_repository.backend_despachos.repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 8081, hostPort = 8081 }]
  }])
}

# Task Definition Backend Ventas
resource "aws_ecs_task_definition" "backend_ventas" {
  family                   = "devops-backend-ventas"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn
  container_definitions = jsonencode([{
    name      = "backend-ventas"
    image     = "${aws_ecr_repository.backend_ventas.repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 8082, hostPort = 8082 }]
  }])
}

# ECS Services
resource "aws_ecs_service" "frontend" {
  name            = "devops-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.publica.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "backend_despachos" {
  name            = "devops-backend-despachos-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_despachos.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.publica.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "backend_ventas" {
  name            = "devops-backend-ventas-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_ventas.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.publica.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
