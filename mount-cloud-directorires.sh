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

FUSE_CONF="/etc/fuse.conf"

# Check if the file exists
if [ ! -f "$FUSE_CONF" ]; then
    echo "$FUSE_CONF does not exist."
    exit 1
fi

# Add or uncomment user_allow_other in /etc/fuse.conf
if grep -q "^# *user_allow_other" "$FUSE_CONF"; then
    sudo sed -i 's/^# *user_allow_other/user_allow_other/' "$FUSE_CONF"
    echo "Uncommented user_allow_other in $FUSE_CONF."
elif ! grep -q "^user_allow_other" "$FUSE_CONF"; then
    echo "user_allow_other" | sudo tee -a "$FUSE_CONF" > /dev/null
    echo "Added user_allow_other to $FUSE_CONF."
else
    echo "user_allow_other is already set in $FUSE_CONF."
fi

mkdir -p ~/.config/rclone
cp ./Config/rclone.conf ~/.config/rclone/rclone.conf


# Create rclone configuration fo MEGA
rclone config create mega mega user "$MEGA_EMAIL" pass "$MEGA_PASSWORD"

MOUNT_DOCKERVOLUMES="rclone mount mega:/DockerVolumes $HOME/DockerVolumes --allow-other --daemon"

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