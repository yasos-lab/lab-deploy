#!/bin/bash

# Install prerequisite packages: 
sudo apt update
sudo apt install ansible

# Install ansible requirements:
ansible-galaxy install -r requirements.yml

# Launch main.yml
ansible-playbook -i inventories/hosts main.yml