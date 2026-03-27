#!/bin/bash

echo "[INFO] Checking prerequisites..."

command -v docker >/dev/null 2>&1 || { echo "[ERROR] Docker not installed"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "[ERROR] Docker Compose not available"; exit 1; }

echo "[INFO] Docker and Compose are installed."


echo "[INFO] Building and starting containers..."
docker compose up -d --build


sleep 5


echo "[INFO] Performing health checks..."

curl -f http://localhost:3000 >/dev/null 2>&1 && echo "[INFO] Port 3000 OK" || echo "[INFO] Port 3000 FAILED"
curl -f http://localhost:5000 >/dev/null 2>&1 && echo "[INFO] Port 5000 OK" || echo "[INFO] Port 5000 FAILED"


echo "[INFO] Listing Docker images..."
docker images


echo "[INFO] Showing running containers..."
docker ps


NGINX_ID=$(docker ps --filter "ancestor=nginx:alpine" --format "{{.ID}}")
echo "[INFO] Captured nginx container ID: $NGINX_ID"


echo "[INFO] Validating web page..."
curl -f http://localhost >/dev/null 2>&1 && echo "[INFO] Page rendered successfully" || echo "[INFO] Page not reachable"


command -v jq >/dev/null 2>&1 || sudo apt-get install -y jq
echo "[INFO] jq is already installed."


echo "[INFO] Inspecting nginx image..."
docker inspect nginx:alpine > nginx-logs.txt
echo "[INFO] Inspection output to 'nginx-logs'."


echo "[INFO] Extracting values from nginx-logs:"
echo ""

echo "RepoTags:"
jq -r '.[0].RepoTags[]' nginx-logs.txt

echo ""
echo "Created:"
jq -r '.[0].Created' nginx-logs.txt

echo ""
echo "OS:"
jq -r '.[0].Os' nginx-logs.txt

echo ""
echo "Config:"
jq '.[0].Config' nginx-logs.txt

echo ""
echo "ExposedPorts:"
jq '.[0].Config.ExposedPorts' nginx-logs.txt


echo ""
echo "[INFO] All tasks completed successfully."