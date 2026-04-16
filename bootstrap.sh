#!/bin/bash

set -e

REPO_DIR="${REPO_DIR:-$HOME/Code/yasos-lab}"
VAULT_PASS="${VAULT_PASS:-$REPO_DIR/.vault-pass}"
ANSIBLE_OPTS="--vault-password-file $VAULT_PASS"

SSH_CONFIG=false
INSTALL=false
WORKSTATION=false

print_usage() {
    echo "Usage: $0 [--install] [--workstation] [--ssh-config] [--test]"
    echo ""
    echo "Options:"
    echo "  --install     | -i           Install Ansible and dependencies"
    echo "  --workstation | -w           Deploy workstation (controller)"
    echo "  --ssh-config  | -s           SSH configuration for the inventory hosts"
    echo "  --help        | -h           Show this help message"
    exit 0
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --ssh-config|-s) SSH_CONFIG=true ;;
        --install|-i) INSTALL=true ;;
        --workstation|-w) WORKSTATION=true ;;
        --help|-h) print_usage ;;
        *) echo "Unknown option: $1" && print_usage ;;
    esac
    shift
done

# Show help if no options were passed
if ! $INSTALL && ! $SSH_CONFIG && ! $WORKSTATION; then
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

    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/deploy-workstation.yml" $ANSIBLE_OPTS
fi

# 3. Run ssh configuration 
if $SSH_CONFIG; then
    echo "🚀 SSH configuration..."

    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/config-ssh.yml" $ANSIBLE_OPTS
    ansible all -m ping -i "$REPO_DIR/inventories/hosts.yml" $ANSIBLE_OPTS
fi
