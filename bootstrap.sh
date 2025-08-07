#!/bin/bash

set -e

REPO_DIR="${REPO_DIR:-$HOME/Code/yasos-lab}"
VAULT_PASS="${VAULT_PASS:-$REPO_DIR/.vault-pass}"
ANSIBLE_OPTS="--vault-password-file $VAULT_PASS"

PROD=false
TEST=false
INSTALL=false

print_usage() {
    echo "Usage: $0 [--install] [--prod] [--test]"
    echo ""
    echo "Options:"
    echo "  --install | -i           Install Ansible and dependencies"
    echo "  --prod    | -p           Run Ansible provisioning for production environment"
    echo "  --test    | -t           Run Ansible provisioning for test environment (docker)"
    echo "  --help    | -h           Show this help message"
    exit 0
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --prod|-p) PROD=true ;;
        --test|-t) TEST=true ;;
        --install|-i) INSTALL=true ;;
        --help|-h) print_usage ;;
        *) echo "Unknown option: $1" && print_usage ;;
    esac
    shift
done

# Show help if no options were passed
if ! $INSTALL && ! $PROD && ! $TEST; then
    echo "❗ No options provided."
    print_usage
fi

# 1. Install Ansible if requested
if $INSTALL; then
    echo "🔧 Installing Ansible..."
    sudo apt update && sudo apt install -y ansible
fi

# 2. Run production provisioning
if $PROD; then
    echo "🚀 Running production setup..."

    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/playbooks/prepare-controller.yml" $ANSIBLE_OPTS
    ansible all -m ping -i "$REPO_DIR/inventories/hosts.yml" $ANSIBLE_OPTS

    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/playbooks/workstation-deploy.yml" $ANSIBLE_OPTS
fi

# 3. Run test environment provisioning
if $TEST; then
    echo "🧪 Running test environment setup..."

    echo "📁 Copying lab directory..."
    TEST_DIR="${REPO_DIR}-test"
    sudo rm -rf "$TEST_DIR" && cp -r "$REPO_DIR" "$TEST_DIR"

    echo "🐳 Remove old Docker containers..."
    docker compose down --remove-orphans

    echo "🐳 Starting Docker containers..."
    docker compose up -d
    
    echo "⏳ Waiting for services to start..."
    sleep 60

    echo "📦 Running Ansible setup on test environment..."
    ansible-playbook -i "$REPO_DIR/inventories/hosts-test.yml" "$REPO_DIR/playbooks/prepare-controller.yml" $ANSIBLE_OPTS
    ansible all -m ping -i "$REPO_DIR/inventories/hosts-test.yml" $ANSIBLE_OPTS
fi
