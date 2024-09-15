#!/bin/bash

# Define variables
USERNAME="$1"
USER_PASS="$2"

# Create a new user and set password
if id "$USERNAME" &>/dev/null; then
  echo "User $USERNAME already exists."
else
  echo "Creating user $USERNAME..."
  sudo useradd -m -s /bin/bash "$USERNAME"
  echo "$USERNAME:$USER_PASS" | sudo chpasswd
  sudo usermod -aG sudo "$USERNAME"
fi

echo "User $USERNAME created and configured."
