#!/bin/bash

set -e 

TOOLS_TO_INSTALL=(
    "zsh"
    "wget"
    "curl" 
    "git"
    "ansible"
    "docker-compose"
    "unzip"
    "python3"
    "python3-pip"
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

detect_linux_distribution

case "$LINUX_DISTRIBUTION" in
    "debian" | "ubuntu")
        apt update
        for tool in "${TOOLS_TO_INSTALL[@]}"; do
            apt install -y "$tool"
        done
        apt install -y build-essential docker.io openjdk-21-jdk
        install_terraform
        ;;
    "redhat" | "centos" | "fedora" | "rhel")
        yum update -y
        for tool in "${TOOLS_TO_INSTALL[@]}"; do
            yum install -y "$tool"
        done
        yum install -y util-linux-user which podman java-21-openjdk-devel
        ln -s $(which podman) /usr/local/bin/docker
        install_terraform
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
