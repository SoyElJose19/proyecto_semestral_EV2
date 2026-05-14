# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-1" # La región por defecto de AWS Academy
}

# Creación de la instancia EC2
resource "aws_instance" "servidor_proyecto" {
  ami           = "ami-0c7217cdde317cfec" # Imagen de Ubuntu 22.04 LTS
  instance_type = "t2.micro"              # Capa gratuita
  key_name      = "vockey"                # Llave por defecto de AWS Academy

  # Configuración de red básica (Asigna IP pública)
  associate_public_ip_address = true

  tags = {
    Name = "EC2-Proyecto-Semestral"
    Environment = "Produccion"
  }
}