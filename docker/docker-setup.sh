#!/bin/bash

# Function to check if the script is run as root
check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges. Please run with sudo."
    exit 1
  fi
}

# Check if the script is being run with sudo
check_root

# Check if the user is already in the docker group
if groups $USER | grep -q "\bdocker\b"; then
  echo "User is already in the docker group."
else
  # Add the user to the docker group
  usermod -aG docker $USER
  echo "User added to the docker group."
  
  # Restart Docker to apply changes
  systemctl restart docker
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
