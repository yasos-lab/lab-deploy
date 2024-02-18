#!/bin/bash

set -e 

# Check if the user is already in the docker group
if groups | grep -q "\bdocker\b"; then
  echo "User is already in the docker group."
else
  # Add the user to the docker group
  sudo usermod -aG docker $USER
  echo "User added to the docker group."
  
  # Restart Docker to apply changes
  sudo systemctl restart docker
  echo "Docker daemon restarted."
fi

# Test Docker permissions
if docker run hello-world &>/dev/null; then
  echo "Docker is working correctly."
  echo "Hello, World! Test: PASSED"
else
  echo "Error: Docker permission test failed."
  echo "Hello, World! Test: FAILED"
  echo "You should logout and login, and re-run the script"
fi