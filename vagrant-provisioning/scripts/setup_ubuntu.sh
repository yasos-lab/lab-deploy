#!/bin/bash

# Define variables
USERNAME="$1"
PASSWORD="$2"

# Create a new user and set password
# Create a new user
echo "Creating user $USERNAME..."
sudo useradd -m "$USERNAME"

# Set the user's password
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Ensure the user's home directory and .ssh directory are created
echo "Setting up SSH directory for $USERNAME..."
sudo mkdir -p /home/"$USERNAME"/.ssh
sudo chmod 700 /home/"$USERNAME"/.ssh

# Create an empty authorized_keys file
sudo touch /home/"$USERNAME"/.ssh/authorized_keys
sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
sudo chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Configure SSH to allow password authentication
echo "Configuring SSH for password authentication..."
sudo sed -i '/^PasswordAuthentication /c\PasswordAuthentication yes' /etc/ssh/sshd_config
sudo sed -i '/^PermitRootLogin /c\PermitRootLogin yes' /etc/ssh/sshd_config

# Restart SSH service to apply changes
echo "Restarting SSH service..."
sudo systemctl restart sshd

echo "User $USERNAME created and password authentication enabled for SSH."

# Provision Linux VM

