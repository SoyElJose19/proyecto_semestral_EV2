#!/bin/bash
# Script de preparación para instancias EC2 del Proyecto Semestral EV2
# Ejecutar en: Frontend y Backend

echo "============================================"
echo "Preparando servidor para Proyecto Semestral"
echo "============================================"

echo "[1/5] Actualizando sistema..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "[2/5] Instalando Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce

echo "[3/5] Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "[4/5] Configurando permisos (usuario no root)..."
sudo usermod -aG docker ubuntu

echo "[5/5] Creando red Docker compartida..."
docker network create backend-network 2>/dev/null || echo "Red ya existe"

echo "============================================"
echo "¡Servidor listo para despliegue!"
echo "Frontend: docker run -d --name frontend -p 80:80 <imagen>"
echo "Backend:  docker run -d --name backend -p 8081:8081 <imagen>"
echo "============================================"
