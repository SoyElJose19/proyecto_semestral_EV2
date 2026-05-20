# ==============================================================================
# PROYECTO SEMESTRAL - ARQUITECTURA AWS ACADEMY (DEV/PROD)
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ====== 1. REDES ======
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "vpc-proyecto-semestral" }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "subnet-public-1" }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = { Name = "subnet-public-2" }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "subnet-private-1" }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "subnet-private-2" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = { Name = "igw-proyecto-semestral" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = { Name = "eip-nat-proyecto-semestral" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = { Name = "nat-proyecto-semestral" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "rt-public" }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "rt-private" }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# ====== 2. SEGURIDAD ======
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-proyecto-semestral"
  description = "Allow HTTP inbound"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-alb" }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg-proyecto-semestral"
  description = "ECS tasks SG"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 8080 # Puerto de tu backend de ventas
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-ecs-tasks" }
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg-proyecto-semestral"
  description = "MySQL access from ECS"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-mysql" }
}

# ====== 3. ECR ======
# Nombres exactos que buscará tu GitHub Actions
resource "aws_ecr_repository" "repo_front" {
  name                 = "proyecto-semestral-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "repo_ventas" {
  name                 = "proyecto-semestral-backend-ventas"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "repo_despachos" {
  name                 = "proyecto-semestral-backend-despachos"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# ====== 4. ECS CLUSTER ======
resource "aws_ecs_cluster" "main_cluster" {
  name = "proyecto-semestral-cluster"
  tags = { Name = "ecs-cluster-principal" }
}

# ====== 5. TASK DEFINITIONS ======
data "aws_iam_role" "existing_execution_role" {
  name = "LabRole"
}

# --- FRONTEND ---
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "proyecto-semestral-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = try(data.aws_iam_role.existing_execution_role.arn, null)

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.repo_front.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/proyecto-semestral-frontend"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# --- BACKEND DESPACHOS ---
resource "aws_ecs_task_definition" "backend_despachos_task" {
  family                   = "proyecto-semestral-backend-despachos"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = try(data.aws_iam_role.existing_execution_role.arn, null)

  container_definitions = jsonencode([{
    name      = "backend-despachos"
    image     = "${aws_ecr_repository.repo_despachos.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8081
      hostPort      = 8081
      protocol      = "tcp"
    }]
    environment = [
      { name = "DB_ENDPOINT", value = "${aws_instance.mysql_srv.private_ip}" },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_NAME", value = "db_despachos" },
      { name = "DB_USERNAME", value = "userdb" },
      { name = "DB_PASSWORD", value = "passdb" },
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${aws_instance.mysql_srv.private_ip}:3306/db_despachos?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/proyecto-semestral-backend-despachos"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# --- BACKEND VENTAS ---
resource "aws_ecs_task_definition" "backend_ventas_task" {
  family                   = "proyecto-semestral-backend-ventas"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = try(data.aws_iam_role.existing_execution_role.arn, null)

  container_definitions = jsonencode([{
    name      = "backend-ventas"
    image     = "${aws_ecr_repository.repo_ventas.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]
    environment = [
      { name = "SERVER_PORT", value = "8080" },
      { name = "DB_ENDPOINT", value = "${aws_instance.mysql_srv.private_ip}" },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_NAME", value = "db_ventas" },
      { name = "DB_USERNAME", value = "userdb" },
      { name = "DB_PASSWORD", value = "passdb" },
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${aws_instance.mysql_srv.private_ip}:3306/db_ventas?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/proyecto-semestral-backend-ventas"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ====== 6. ALB (Load Balancer) ======
resource "aws_lb" "front_alb" {
  name               = "proyecto-semestral-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"
}

resource "aws_lb_target_group" "despachos_tg" {
  name        = "despachos-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"
  health_check {
    path    = "/"
    matcher = "200,404,401,403"
  }
}

resource "aws_lb_target_group" "ventas_tg" {
  name        = "ventas-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"
  health_check {
    path    = "/"
    matcher = "200,404,401,403"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.front_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener_rule" "despachos_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.despachos_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/despachos*"]
    }
  }
}

resource "aws_lb_listener_rule" "ventas_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ventas_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/ventas*"]
    }
  }
}

# ====== 7. ECS SERVICES ======
resource "aws_ecs_service" "frontend_service" {
  name            = "proyecto-semestral-frontend-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "backend_despachos_service" {
  name            = "proyecto-semestral-backend-despachos-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.backend_despachos_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.despachos_tg.arn
    container_name   = "backend-despachos"
    container_port   = 8081
  }

  depends_on = [aws_lb_listener_rule.despachos_rule]
}

resource "aws_ecs_service" "backend_ventas_service" {
  name            = "proyecto-semestral-backend-ventas-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.backend_ventas_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ventas_tg.arn
    container_name   = "backend-ventas"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener_rule.ventas_rule]
}

# ====== 8. EC2 PARA MYSQL ======
resource "aws_instance" "mysql_srv" {
  ami                    = "ami-0c7217cdde317cfec"  # AMI Amazon Linux 2023 us-east-1
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  key_name               = "vockey"
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Truco para esperar a que Docker despierte
    until docker info > /dev/null 2>&1; do
      sleep 2
    done

    mkdir -p /opt/mysql-init
    cat > /opt/mysql-init/init.sql <<SQL
    CREATE DATABASE IF NOT EXISTS db_despachos;
    CREATE DATABASE IF NOT EXISTS db_ventas;
    GRANT ALL PRIVILEGES ON db_despachos.* TO 'userdb'@'%';
    GRANT ALL PRIVILEGES ON db_ventas.* TO 'userdb'@'%';
    FLUSH PRIVILEGES;
    SQL

    docker run -d \
      --name mysql_db \
      --restart always \
      -p 3306:3306 \
      -v mysql_data:/var/lib/mysql \
      -v /opt/mysql-init:/docker-entrypoint-initdb.d \
      -e MYSQL_ROOT_PASSWORD=rootpassword \
      -e MYSQL_USER=userdb \
      -e MYSQL_PASSWORD=passdb \
      mysql:8.0
  EOF
  )

  tags = { Name = "EC2-MySQL-Proyecto" }
}
# ====== 9. CLOUDWATCH LOGS ======
resource "aws_cloudwatch_log_group" "ecs_frontend" {
  name = "/ecs/proyecto-semestral-frontend"
  tags = { Name = "log-frontend" }
}

resource "aws_cloudwatch_log_group" "ecs_backend_despachos" {
  name = "/ecs/proyecto-semestral-backend-despachos"
  tags = { Name = "log-despachos" }
}

resource "aws_cloudwatch_log_group" "ecs_backend_ventas" {
  name = "/ecs/proyecto-semestral-backend-ventas"
  tags = { Name = "log-ventas" }
}

# ====== 10. OUTPUTS ======
output "alb_dns_name" {
  value       = aws_lb.front_alb.dns_name
  description = "DNS del ALB para acceder al Frontend en el navegador"
}

output "mysql_private_ip" {
  value       = aws_instance.mysql_srv.private_ip
  description = "IP privada de MySQL"
}