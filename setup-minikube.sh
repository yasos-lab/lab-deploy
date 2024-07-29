#!/bin/bash

install_minikube_and_kubectl() {
    if command -v minikube &>/dev/null; then
        echo "Minikube is already installed."
    else
        echo "Installing minikube."
        wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    fi
    if command -v kubectl &>/dev/null; then
        echo "kubectl is already installed."
    else
        echo "Installing kubectl."
        wget "https://dl.k8s.io/release/$(wget -q -O - https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        mv kubectl /usr/local/bin/
    fi
}

install_minikube_and_kubectl

# Run minikube:
echo "Starting minikube."
minikube start --driver=docker
