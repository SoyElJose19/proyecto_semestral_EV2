# ============================================
# Configuración del proveedor AWS
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

# ============================================
# Subredes
# ============================================
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

# ============================================
# Internet Gateway
# ============================================
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
resource "aws_security_group" "frontend" {
  name   = "${var.project_name}-sg-frontend"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP desde Internet"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH administracion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-frontend" }
}

resource "aws_security_group" "backend" {
  name   = "${var.project_name}-sg-backend"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8081
    to_port         = 8082
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
    description     = "APIs desde Frontend"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-backend" }
}

# ============================================
# EC2 Frontend (Pública)
# ============================================
resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.frontend.id]

  tags = {
    Name = "${var.project_name}-frontend"
  }
  user_data = file("setup_ec2.sh")
}

# ============================================
# EC2 Backend (Privada)
# ============================================
resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.privada.id
  vpc_security_group_ids = [aws_security_group.backend.id]

  tags = {
    Name = "${var.project_name}-backend"
  }
}

# ============================================
# Elastic IP para Frontend
# ============================================
resource "aws_eip" "frontend" {
  instance = aws_instance.frontend.id
  tags     = { Name = "${var.project_name}-eip" }
}