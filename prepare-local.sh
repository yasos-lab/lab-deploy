#!/bin/bash

sudo apt update
sudo apt install ansible
sudo apt install git
sudo apt install virtualbox
sudo apt install vagrant

ansible-galaxy install -r requirements.yaml


