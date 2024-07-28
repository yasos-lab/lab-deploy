#!/bin/bash

# Install tools:
echo "[TOOLS] Install packages."
./install-tools.sh

# Setup Docker:
echo "[DOCKER] Setup docker."
./Docker/docker-setup.sh

# Run Portainer:
echo "[DOCKER] [PORTAINER] Run portainer."
docker-compose -f ./Docker/Portainer/docker-compose.yml up -d