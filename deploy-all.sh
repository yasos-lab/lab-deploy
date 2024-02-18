#!/bin/bash

set -e 

echo "[ALL] Deploy all."

# Install tools:
echo "[TOOLS] Install tools."
./install-tools.sh

# Setup Docker:
echo "[DOCKER] Setup docker."
./Docker/docker-setup.sh

# Run Portainer:
echo "[DOCKER] [PORTAINER] Run portainer."
docker-compose -f ./Docker/Portainer/docker-compose.yml up -d

# Run minikube:
#echo "[KUBE] Start minikube."
#minikube start --driver=docker