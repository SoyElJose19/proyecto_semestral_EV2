
provider "aws" {
  region = var.aws_region
}

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

resource "aws_subnet" "privada" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_privada_cidr
  tags = { Name = "${var.project_name}-subnet-privada" }
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

resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-sg-database"
  description = "Security group para PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "PostgreSQL acceso"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH acceso"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Trafico saliente"
  }

  tags = { Name = "${var.project_name}-sg-database" }
}

resource "aws_instance" "database" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  user_data     = file("setup_ec2.sh")

  tags = {
    Name = "${var.project_name}-database"
  }
}

resource "aws_eip" "database" {
  instance = aws_instance.database.id
  tags     = { Name = "${var.project_name}-eip" }
}

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
