#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install a package if not already installed
install_if_not_exists() {
  if ! command_exists "$1"; then
    echo "Installing $1..."
    sudo apt-get install -y "$1"
  else
    echo "$1 is already installed."
  fi
}

echo "Updating package list..."
sudo apt-get update

# 1. Install VirtualBox
echo "Checking for VirtualBox..."
if ! command_exists "vboxmanage"; then
  echo "Installing VirtualBox..."
  sudo apt-get install -y virtualbox
else
  echo "VirtualBox is already installed."
fi

# 2. Install Vagrant
echo "Adding HashiCorp repository..."
sudo apt-get install -y software-properties-common curl gnupg
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com focal main"

# 3. Install Vagrant
echo "Checking for Vagrant..."
if ! command_exists "vagrant"; then
  echo "Installing Vagrant..."
  sudo apt-get install -y vagrant
else
  echo "Vagrant is already installed."
fi

echo "Adding necessary Vagrant boxes..."

# Ubuntu 20.04 LTS (Linux Server)
if ! vagrant box list | grep -q "ubuntu/focal64"; then
  echo "Adding Ubuntu 20.04 (focal64) box..."
  vagrant box add ubuntu/focal64
else
  echo "Ubuntu 20.04 (focal64) box is already added."
fi

# Windows 10
if ! vagrant box list | grep -q "universalvishwa/windows-10-professional-x64"; then
  echo "Adding Windows 10 box..."
  vagrant box add universalvishwa/windows-10-professional-x64
else
  echo "Windows Server 2019 box is already added."
fi

# FreeBSD (TrueNAS simulation)
if ! vagrant box list | grep -q "freebsd/FreeBSD-12.2-RELEASE"; then
  echo "Adding FreeBSD 12.2-RELEASE box..."
  vagrant box add freebsd/FreeBSD-12.2-RELEASE --provider virtualbox
else
  echo "FreeBSD 12.2-RELEASE box is already added."
fi

# Final message
echo "Vagrant, VirtualBox, and necessary boxes are installed. You're ready to go!"

echo "Create and start Vagrant instances..."
./vagrant-manage.sh start
