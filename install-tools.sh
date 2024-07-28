#!/bin/bash

set -e 

TOOLS_TO_INSTALL=(
    "wget"
    "git"
    "ansible"
    "unzip"
    "python3"
    "python3-pip"
    "openjdk-21-jdk"
    "maven"
)

detect_linux_distribution() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [ -n "$ID" ]; then
            LINUX_DISTRIBUTION="$ID"
        fi
    elif [ -f /etc/redhat-release ]; then
        LINUX_DISTRIBUTION="redhat"
    elif [ -f /etc/debian_version ]; then
        LINUX_DISTRIBUTION="debian"
    else
        LINUX_DISTRIBUTION="unknown"
    fi
}

install_terraform() {
    if command -v terraform &>/dev/null; then
        echo "Terraform is already installed."
    else
        wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
        unzip terraform_1.6.0_linux_amd64.zip
        chmod +x terraform
        mv terraform /usr/local/bin/
        rm terraform_1.6.0_linux_amd64.zip
        echo "Terraform installation completed."
    fi
}

install_minikube_and_kubectl() {
    if command -v minikube &>/dev/null; then
        echo "Minikube is already installed."
    else
        wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    fi
    if command -v kubectl &>/dev/null; then
        echo "kubectl is already installed."
    else
        wget "https://dl.k8s.io/release/$(wget -q -O - https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        mv kubectl /usr/local/bin/
    fi
}

detect_linux_distribution

case "$LINUX_DISTRIBUTION" in
    "debian" | "ubuntu")
        apt update
        for tool in "${TOOLS_TO_INSTALL[@]}"; do
            apt install -y "$tool"
        done
        apt install -y build-essential docker.io docker-compose
        install_terraform
        install_minikube_and_kubectl
        ;;
    "redhat" | "centos" | "fedora" | "rhel")
        yum update -y
        for tool in "${TOOLS_TO_INSTALL[@]}"; do
            yum install -y "$tool"
        done
        yum install -y podman
        ln -s $(which podman) /usr/local/bin/docker
        install_terraform
        install_minikube_and_kubectl
        ;;
    *)
        echo "Unsupported or unknown Linux distribution: $LINUX_DISTRIBUTION"
        exit 1
        ;;
esac

if [ "$LINUX_DISTRIBUTION" == "debian" ] || [ "$LINUX_DISTRIBUTION" == "ubuntu" ]; then
    apt autoremove -y
    apt clean
elif [ "$LINUX_DISTRIBUTION" == "redhat" ] || [ "$LINUX_DISTRIBUTION" == "centos" ] || [ "$LINUX_DISTRIBUTION" == "fedora" ] || [ "$LINUX_DISTRIBUTION" == "rhel" ]; then
    yum clean all
fi

echo "Installation of tools completed for $LINUX_DISTRIBUTION."
