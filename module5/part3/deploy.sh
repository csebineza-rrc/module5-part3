#!/bin/bash

echo "===== STEP 1: Check prerequisites ====="

# Check Docker
if ! command -v docker &> /dev/null
then
    echo "Docker is NOT installed"
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose is NOT installed"
    exit 1
fi

echo "Docker and Compose are installed ✅"


echo "===== STEP 2: Go to project directory ====="

cd "$(dirname "$0")" || exit

# Check docker-compose file
if [ ! -f "docker-compose.yml" ]; then
    echo "docker-compose.yml not found ❌"
    exit 1
fi

echo "docker-compose.yml found ✅"


echo "===== STEP 3: Build & Deploy ====="

docker-compose up -d --build

echo "Containers started ✅"


echo "===== STEP 4: Health Check ====="

sleep 5

curl -f http://localhost:3000 && echo "Port 3000 OK ✅" || echo "Port 3000 FAILED ❌"
curl -f http://localhost:5000 && echo "Port 5000 OK ✅" || echo "Port 5000 FAILED ❌"


echo "===== STEP 5: List images ====="

docker images


echo "===== STEP 6: Show running containers ====="

docker ps


echo "===== STEP 7: Get nginx container ID ====="

NGINX_ID=$(docker ps | grep nginx | awk '{print $1}')

echo "Nginx Container ID: $NGINX_ID"


echo "===== STEP 8: Validate page ====="

curl http://localhost || echo "Page not reachable ❌"


echo "===== STEP 9: Check jq ====="

if ! command -v jq &> /dev/null
then
    echo "jq not installed, installing..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

echo "jq is installed ✅"


echo "===== STEP 10: Inspect nginx image ====="

docker inspect nginx:alpine > nginx-logs.txt

echo "Logs saved to nginx-logs.txt ✅"


echo "===== STEP 11: Extract values ====="

echo "RepoTags:"
jq '.[0].RepoTags' nginx-logs.txt

echo "Created:"
jq '.[0].Created' nginx-logs.txt

echo "OS:"
jq '.[0].Os' nginx-logs.txt

echo "Config:"
jq '.[0].Config' nginx-logs.txt

echo "ExposedPorts:"
jq '.[0].Config.ExposedPorts' nginx-logs.txt