# ============================================
# Proveedor AWS
# ============================================
provider "aws" {
  region = var.aws_region
}

# ============================================
# VPC
# ============================================
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_publica_cidr
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-subnet-publica" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-igw" }
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

# ============================================
# Security Groups
# ============================================
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-sg-ecs"
  description = "Security group for ECS services"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Backend APIs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = { Name = "${var.project_name}-sg-ecs" }
}

# ============================================
# ECR - Repositorios de imágenes
# ============================================
resource "aws_ecr_repository" "frontend" {
  name = "${var.project_name}-frontend"
  tags = { Name = "${var.project_name}-ecr-frontend" }
}

resource "aws_ecr_repository" "backend_despachos" {
  name = "${var.project_name}-backend-despachos"
  tags = { Name = "${var.project_name}-ecr-despachos" }
}

resource "aws_ecr_repository" "backend_ventas" {
  name = "${var.project_name}-backend-ventas"
  tags = { Name = "${var.project_name}-ecr-ventas" }
}

# ============================================
# ECS Cluster
# ============================================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  tags = { Name = "${var.project_name}-cluster" }
}

# ============================================
# ECS Task Definitions
# ============================================
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
  task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/LabRole"

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.frontend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_task_definition" "backend_despachos" {
  family                   = "${var.project_name}-backend-despachos"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
  task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/LabRole"

  container_definitions = jsonencode([{
    name      = "backend-despachos"
    image     = "${aws_ecr_repository.backend_despachos.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8081
      hostPort      = 8081
    }]
    environment = [
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}/${var.db_name}" },
      { name = "SPRING_DATASOURCE_USERNAME", value = var.db_username },
      { name = "SPRING_DATASOURCE_PASSWORD", value = var.db_password }
    ]
  }])
}

resource "aws_ecs_task_definition" "backend_ventas" {
  family                   = "${var.project_name}-backend-ventas"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/LabRole"
  task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/LabRole"

  container_definitions = jsonencode([{
    name      = "backend-ventas"
    image     = "${aws_ecr_repository.backend_ventas.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8082
      hostPort      = 8082
    }]
    environment = [
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}/${var.db_name}" },
      { name = "SPRING_DATASOURCE_USERNAME", value = var.db_username },
      { name = "SPRING_DATASOURCE_PASSWORD", value = var.db_password }
    ]
  }])
}

# ============================================
# ECS Services
# ============================================
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-service"
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
  name            = "${var.project_name}-backend-despachos-service"
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
  name            = "${var.project_name}-backend-ventas-service"
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

# ============================================
# RDS PostgreSQL
# ============================================
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  tags = { Name = "${var.project_name}-db" }
}
