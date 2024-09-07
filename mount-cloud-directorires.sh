#!/bin/bash

source ~/.secrets

install_and_config_rclone() {
    if ! command -v rclone &> /dev/null; then
        echo "rclone not found. Installing..."
        curl https://rclone.org/install.sh | sudo bash
    else
        echo "rclone is already installed."
    fi

    mkdir -p ~/.config/rclone
    touch ~/.config/rclone/rclone.conf
}

allow_other_users() {
    local fuse_conf="/etc/fuse.conf"

    # Check if the file exists
    if [ ! -f "$fuse_conf" ]; then
        echo "$fuse_conf does not exist."
        exit 1
    fi

    # Add or uncomment user_allow_other in /etc/fuse.conf
    if grep -q "^# *user_allow_other" "$fuse_conf"; then
        sudo sed -i 's/^# *user_allow_other/user_allow_other/' "$fuse_conf"
        echo "Uncommented user_allow_other in $fuse_conf."
    elif ! grep -q "^user_allow_other" "$fuse_conf"; then
        echo "user_allow_other" | sudo tee -a "$fuse_conf" > /dev/null
        echo "Added user_allow_other to $fuse_conf."
    else
        echo "user_allow_other is already set in $fuse_conf."
    fi
}

mount_cloud() {

    local provider=$1
    local mount_label=$2
    local provider_username=$3
    local provider_password=$4

    #local mount_command="rclone mount $provider:/ $HOME/$mount_label --allow-other --daemon"
    local mount_command="rclone mount $provider:/ $HOME/$mount_label --daemon"
    
    # Create rclone configuration for cloud provider
    rclone config create $provider $provider user "$provider_username" pass "$provider_password"

    # Mount cloud directory
    mkdir -p $HOME/$mount_label
    eval "$mount_command"

    # Add mount command to .zshrc if not already present
    if ! grep -q "$mount_command" ~/.zshrc; then
        echo "$mount_command" >> ~/.zshrc
        echo "Mount command added to .zshrc."
    else
        echo "Mount command already exists in .zshrc."
    fi
}

# Install Rclone
install_and_config_rclone

# Allow Other User
#allow_other_users

# Mount Cloud
mount_cloud 'mega' 'Mega' $MEGA_EMAIL $MEGA_PASSWORD
mount_cloud drive G-Drive $GGL_EMAIL $GGL_PASSWORD
mount_cloud onedrive 1-Drive $MSFT_EMAIL $MSFT_PASSWORD
mount_cloud dropbox Dropbox $DROPBOX_EMAIL $DROPBOX_PASSWORD