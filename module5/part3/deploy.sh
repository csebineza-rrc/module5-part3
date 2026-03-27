#!/bin/bash

echo "[INFO] ===== STEP 1: Check prerequisites ====="

# Check Docker
if ! command -v docker &> /dev/null
then
    echo "[ERROR] Docker is NOT installed"
    exit 1
fi

# Use modern docker compose (instead of docker-compose)
if ! docker compose version &> /dev/null
then
    echo "[ERROR] Docker Compose is NOT available"
    exit 1
fi

echo "[INFO] Docker and Compose are installed ✅"


echo ""
echo "[INFO] ===== STEP 2: Go to project directory ====="

cd "$(dirname "$0")" || exit

if [ ! -f "docker-compose.yml" ]; then
    echo "[ERROR] docker-compose.yml not found ❌"
    exit 1
fi

echo "[INFO] docker-compose.yml found ✅"


echo ""
echo "[INFO] ===== STEP 3: Build & Deploy ====="

docker compose up -d --build

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to build/start containers ❌"
    exit 1
fi

echo "[INFO] Containers started successfully ✅"


echo ""
echo "[INFO] ===== STEP 4: Health Check ====="

sleep 5

curl -f http://localhost:3000 &> /dev/null \
    && echo "[INFO] Port 3000 OK ✅" \
    || echo "[WARNING] Port 3000 FAILED ❌"

curl -f http://localhost:5000 &> /dev/null \
    && echo "[INFO] Port 5000 OK ✅" \
    || echo "[WARNING] Port 5000 FAILED ❌"


echo ""
echo "[INFO] ===== STEP 5: List Docker Images ====="

docker images


echo ""
echo "[INFO] ===== STEP 6: Show running containers ====="

docker ps


echo ""
echo "[INFO] ===== STEP 7: Get nginx container ID ====="

NGINX_ID=$(docker ps --filter "ancestor=nginx:alpine" --format "{{.ID}}")

if [ -z "$NGINX_ID" ]; then
    echo "[WARNING] No nginx container found ❌"
else
    echo "[INFO] Nginx Container ID: $NGINX_ID"
fi


echo ""
echo "[INFO] ===== STEP 8: Validate page ====="

curl -f http://localhost &> /dev/null \
    && echo "[INFO] Web page reachable ✅" \
    || echo "[WARNING] Page not reachable ❌"


echo ""
echo "[INFO] ===== STEP 9: Check jq ====="

if ! command -v jq &> /dev/null
then
    echo "[INFO] jq not installed, installing..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

echo "[INFO] jq is installed ✅"


echo ""
echo "[INFO] ===== STEP 10: Inspect nginx image ====="

docker inspect nginx:alpine > nginx-logs.txt

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to inspect nginx image ❌"
    exit 1
fi

echo "[INFO] nginx inspection output saved to nginx-logs.txt ✅"


echo ""
echo "[INFO] ===== STEP 11: Extracting values from nginx-logs ====="

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
echo "[INFO] All tasks completed successfully ✅"