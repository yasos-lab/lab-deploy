#!/bin/bash

echo "[ALL] Deploy all."

# Install tools:
echo "[TOOLS] Install tools."
./install-tools.sh

# Setup Docker:
echo "[DOCKER] Setup docker."
./Docker/docker-setup.sh

# Run minikube:
echo "[KUBE] Start minikube."
minikube start --driver=docker

# Create VMs:
echo "[VMs] Create virtual machines."

