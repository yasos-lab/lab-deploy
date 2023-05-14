#!/bin/bash

# Install prerequisite packages: 
apt update
apt install ansible

# Install ansible requirements:
ansible-galaxy install -r requirements.yml

# Launch main.yml
ansible-playbook -i inventories/local/hosts main.yml