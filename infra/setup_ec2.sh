cat > infra/setup_ec2.sh << 'EOF'
#!/bin/bash
echo "============================================"
echo "Preparando servidor PostgreSQL"
echo "============================================"

echo "[1/4] Actualizando sistema..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "[2/4] Instalando Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce

echo "[3/4] Configurando permisos..."
sudo usermod -aG docker ubuntu

echo "[4/4] Iniciando PostgreSQL..."
docker network create backend-network 2>/dev/null || true
docker run -d --name postgres-db \
  --network backend-network \
  --restart unless-stopped \
  -p 5432:5432 \
  -e POSTGRES_DB=despachos_ventas_db \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=SecurePassword123! \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15-alpine

echo "============================================"
echo "¡PostgreSQL listo en puerto 5432!"
echo "============================================"
EOF