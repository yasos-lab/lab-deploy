#!/bin/bash

source ~/.env

install_rclone() {
    if ! command -v rclone &> /dev/null; then
        echo "rclone not found. Installing..."
        curl https://rclone.org/install.sh | sudo bash
    else
        echo "rclone is already installed."
    fi
}

# Install Rclone
install_rclone

mkdir -p ~/.config/rclone
cp ./Config/rclone.conf ~/.config/rclone/rclone.conf


# Create rclone configuration fo MEGA
rclone config create mega mega user "$MEGA_EMAIL" pass "$MEGA_PASSWORD"

MOUNT_DOCKERVOLUMES="rclone mount mega:/DockerVolumes $HOME/DockerVolumes --daemon"

# Mount DockerVolumes
mkdir -p $HOME/DockerVolumes
eval "$MOUNT_DOCKERVOLUMES"

# Add mount command to .zshrc if not already present
if ! grep -q "$MOUNT_DOCKERVOLUMES" ~/.zshrc; then
    echo "$MOUNT_DOCKERVOLUMES" >> ~/.zshrc
    echo "Mount command added to .zshrc."
else
    echo "Mount command already exists in .zshrc."
fi