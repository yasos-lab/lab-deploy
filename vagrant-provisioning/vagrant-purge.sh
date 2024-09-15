#!/bin/bash

# Function to remove a package if installed
remove_if_exists() {
  if command_exists "$1"; then
    echo "Removing $1..."
    sudo apt-get remove --purge -y "$1"
    sudo apt-get autoremove -y
  else
    echo "$1 is not installed."
  fi
}

# Function to remove a Vagrant box if it exists
remove_vagrant_box() {
  if vagrant box list | grep -q "$1"; then
    echo "Removing Vagrant box $1..."
    vagrant box remove "$1" --force
  else
    echo "Vagrant box $1 is not installed."
  fi
}

echo "Stoping and removing Vagrant instances..."
./vagrant-manage.sh remove

echo "Removing VirtualBox and Vagrant..."

# Remove VirtualBox
remove_if_exists "virtualbox"

# Remove Vagrant
remove_if_exists "vagrant"

# Remove Vagrant boxes
echo "Removing Vagrant boxes..."
remove_vagrant_box "ubuntu/focal64"
remove_vagrant_box "universalvishwa/windows-10-professional-x64"
remove_vagrant_box "freebsd/FreeBSD-12.2-RELEASE"

echo "Cleanup complete. All specified packages and Vagrant boxes have been removed."
