#!/bin/bash

# Install the Vagrant Docker Compose plugin
vagrant plugin list | grep -q "vagrant-docker-compose"
if [ $? -eq 0 ]; then
  echo "Vagrant Docker Compose plugin is already installed."
else
  vagrant plugin install vagrant-docker-compose
  echo "Vagrant Docker Compose plugin installed."
fi

# Create a directory for your Vagrant project
mkdir -p ~/vagrant-projects/my-docker-project
cd ~/vagrant-projects/my-docker-project

# Create a Vagrantfile for Docker provider
cat <<EOL > Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |docker|
    docker.image = "ubuntu:20.04"
  end
end
EOL

echo "Vagrant environment configured with Docker provider."
echo "You can now use 'vagrant up' to create and provision Docker-based VMs."