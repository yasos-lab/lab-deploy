#!/bin/bash

set -e

REPO_DIR="${REPO_DIR:-$HOME/Code/yasos-lab}"
VAULT_PASS="${VAULT_PASS:-$REPO_DIR/.vault-pass}"
ANSIBLE_OPTS="--vault-password-file $VAULT_PASS"

PROD=false
TEST=false
INSTALL=false
WORKSTATION=false

print_usage() {
    echo "Usage: $0 [--install] [--workstation] [--prod] [--test]"
    echo ""
    echo "Options:"
    echo "  --install     | -i           Install Ansible and dependencies"
    echo "  --workstation | -w           Deploy workstation (controller)"
    echo "  --prod        | -p           Prepare production environment"
    echo "  --test        | -t           Prepare test environment (docker)"
    echo "  --help        | -h           Show this help message"
    exit 0
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --prod|-p) PROD=true ;;
        --test|-t) TEST=true ;;
        --install|-i) INSTALL=true ;;
        --workstation|-w) WORKSTATION=true ;;
        --help|-h) print_usage ;;
        *) echo "Unknown option: $1" && print_usage ;;
    esac
    shift
done

# Show help if no options were passed
if ! $INSTALL && ! $PROD && ! $TEST && ! $WORKSTATION; then
    echo "❗ No options provided."
    print_usage
fi

# 1. Install Ansible if requested
if $INSTALL; then
    echo "🔧 Installing Ansible..."
    sudo apt update && sudo apt install -y ansible
fi

# 2. Run workstation provisioning
if $WORKSTATION; then
    echo "🚀 Running workstation setup..."

    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/playbooks/workstation-deploy.yml" $ANSIBLE_OPTS
fi
    

# 3. Run production prepare
if $PROD; then
    echo "🚀 Preparing production environment..."

    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/playbooks/prepare-controller.yml" $ANSIBLE_OPTS
    ansible all -m ping -i "$REPO_DIR/inventories/hosts.yml" $ANSIBLE_OPTS
fi

# 4. Run test environment prepare
if $TEST; then
    echo "🧪 Preparing test environment..."

    echo "📁 Copying lab directory..."
    TEST_DIR="${REPO_DIR}-test"
    sudo rm -rf "$TEST_DIR" && cp -r "$REPO_DIR" "$TEST_DIR"

    echo "🐳 Remove old Docker containers..."
    docker compose down --remove-orphans

    echo "🐳 Starting Docker containers..."
    docker compose up -d
    
    WAIT_TIME="${WAIT_TIME:-60}"
    echo "⏳ Waiting for services to start (${WAIT_TIME}s)..."
    sleep "$WAIT_TIME"

    echo "📦 Running Ansible setup on test environment..."
    ansible-playbook -i "$REPO_DIR/inventories/hosts-test.yml" "$REPO_DIR/playbooks/prepare-controller.yml" $ANSIBLE_OPTS
    ansible all -m ping -i "$REPO_DIR/inventories/hosts-test.yml" $ANSIBLE_OPTS
fi
