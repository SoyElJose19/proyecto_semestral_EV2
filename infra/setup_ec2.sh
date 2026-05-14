#!/bin/bash
# Script de preparación para la instancia EC2 (Ubuntu) en AWS Academy

echo "Actualizando el sistema operativo..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Instalando Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce

echo "Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Configurando permisos de usuario (IE1 - Seguridad)..."
sudo usermod -aG docker ubuntu

echo "¡Servidor listo! Por favor, cierra sesión por SSH y vuelve a entrar para aplicar los permisos."