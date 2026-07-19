#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO_DIR:-$SCRIPT_DIR}"
VAULT_PASS="${VAULT_PASS:-$REPO_DIR/.vault-pass}"
ANSIBLE_OPTS="--vault-password-file $VAULT_PASS"

SSH_CONFIG=false
INSTALL=false
WORKSTATION=false

log() { echo "[+] $*"; }
err() { echo "[-] $*" >&2; }

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    elif command -v apk &>/dev/null; then
        echo "apk"
    else
        echo ""
    fi
}

install_ansible() {
    local pkg_mgr
    pkg_mgr="$(detect_pkg_manager)"

    if [[ -z "$pkg_mgr" ]]; then
        err "No supported package manager found (apt/dnf/yum/pacman/zypper/apk)."
        err "Install Ansible manually: https://docs.ansible.com/ansible/latest/installation_guide/"
        exit 1
    fi

    if command -v ansible &>/dev/null; then
        log "Ansible is already installed: $(ansible --version | head -1)"
        return 0
    fi

    log "Detected package manager: $pkg_mgr"
    log "Installing Ansible..."

    case "$pkg_mgr" in
        apt)
            sudo apt-get update -y
            sudo apt-get install -y ansible
            ;;
        dnf)
            sudo dnf install -y epel-release 2>/dev/null || true
            sudo dnf install -y ansible
            ;;
        yum)
            sudo yum install -y epel-release 2>/dev/null || true
            sudo yum install -y ansible
            ;;
        pacman)
            sudo pacman -Syu --noconfirm ansible
            ;;
        zypper)
            sudo zypper install -y ansible
            ;;
        apk)
            sudo apk add --no-cache ansible
            ;;
    esac

    log "Ansible installed successfully."
}

print_usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --install     | -i    Install Ansible and dependencies
  --workstation | -w    Deploy workstation (controller)
  --ssh-config  | -s    SSH configuration for the inventory hosts
  --help        | -h    Show this help message
EOF
    exit 0
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --ssh-config|-s)  SSH_CONFIG=true ;;
        --install|-i)     INSTALL=true ;;
        --workstation|-w) WORKSTATION=true ;;
        --help|-h)        print_usage ;;
        *) err "Unknown option: $1"; print_usage ;;
    esac
    shift
done

if ! $INSTALL && ! $SSH_CONFIG && ! $WORKSTATION; then
    err "No options provided."
    print_usage
fi

if [[ ! -d "$REPO_DIR/inventories" ]]; then
    err "Inventory directory not found at $REPO_DIR/inventories"
    err "Ensure you are running this script from within the lab-deploy repo."
    exit 1
fi

if $INSTALL; then
    install_ansible
fi

if $WORKSTATION; then
    log "Running workstation setup..."
    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/deploy-workstation.yml" $ANSIBLE_OPTS
fi

if $SSH_CONFIG; then
    log "SSH configuration..."
    ansible-playbook -i "$REPO_DIR/inventories/hosts.yml" "$REPO_DIR/config-ssh.yml" $ANSIBLE_OPTS
    ansible all -m ping -i "$REPO_DIR/inventories/hosts.yml" $ANSIBLE_OPTS
fi
