#!/bin/bash

sudo apt update
sudo apt install openssh-server
sudo apt install ansible
sudo apt install git
sudo apt install virtualbox
sudo apt install vagrant

ssh-keygen

ansible-galaxy install -r requirements.yaml


