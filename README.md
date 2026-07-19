# lab-deploy

Ansible repository for managing homelab infrastructure: Proxmox, Kubernetes, Docker, networking, and workstation setup.

## Prerequisites

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) (installed automatically via `bootstrap.sh --install`)
- Python 3 on all managed hosts
- SSH access to inventory hosts

## Getting Started

```bash
# 1. Install Ansible
./bootstrap.sh --install

# 2. Configure SSH and verify connectivity
./bootstrap.sh --ssh-config

# 3. Set up the workstation (controller node)
./bootstrap.sh --workstation
```

### Bootstrap Options

| Flag | Description |
|---|---|
| `--install`, `-i` | Install Ansible via the system package manager |
| `--ssh-config`, `-s` | Deploy SSH configuration and ping all hosts |
| `--workstation`, `-w` | Run the workstation setup playbook |
| `--help`, `-h` | Show usage information |

## Project Structure

```
.
├── ansible.cfg                  # Ansible configuration
├── bootstrap.sh                 # Setup script (install, SSH, workstation)
├── requirements.yml             # Ansible Galaxy collection dependencies
├── inventories/
│   ├── hosts.yml                # Host definitions and groups
│   └── group_vars/              # Variables per group
│       ├── all/                 # Shared variables, secrets, docker, monitoring
│       ├── k8s/                 # Kubernetes variables
│       ├── network/             # Network/router variables
│       ├── proxmox/             # Proxmox variables
│       └── workstations/        # Workstation variables
├── tasks/
│   ├── common/                  # Shared tasks (packages, repos, filesystem, rclone, restic)
│   ├── docker/                  # Docker installation and services
│   ├── k8s/                     # Kubernetes setup (numbered 01-05)
│   ├── network/                 # Network/router tasks
│   └── handlers/                # Reusable handlers
├── templates/                   # Jinja2 templates
├── files/                       # Static files
└── miscs/                       # Miscellaneous resources
```

## Playbooks

| Playbook | Target Group | Description |
|---|---|---|
| `deploy-docker-node.yml` | `docker_node` | Docker host setup and services |
| `deploy-jellyfin-node.yml` | `jellyfin_node` | Jellyfin media server |
| `deploy-kubernetes.yml` | `k8s` | Kubernetes cluster (controlplanes + workers) |
| `deploy-workstation.yml` | `workstations` | Controller/workstation configuration |
| `config-ssh.yml` | `all` | SSH key deployment and config |
| `config-network.yml` | `network` | Network and router configuration |
| `config-proxmox.yml` | `proxmox` | Proxmox host configuration |
| `debug.yml` | `all` | Debug/fact-gathering playbook |

## Inventory

Host groups defined in `inventories/hosts.yml`:

- **docker_node** — Docker host
- **jellyfin_node** — Jellyfin media server
- **workstations** — Controller nodes (e.g. ThinkPad)
- **network** — Raspberry Pi router(s)
- **proxmox** — Proxmox VE host
- **k8s** — Kubernetes cluster
  - **k8s_controlplanes** — Control plane nodes
  - **k8s_workers** — Worker nodes

## Secrets Management

- Secrets are stored in `inventories/group_vars/all/secrets.yml` (Ansible Vault encrypted).
- Create a `.vault-pass` file in the repo root containing your vault password. This file is gitignored.
- Pass `--vault-password-file .vault-pass` when running playbooks manually.

**Never commit `.vault-pass` or decrypt vault-encrypted files.**

## Running Playbooks

```bash
# Run a playbook against all targeted hosts
ansible-playbook -i inventories/hosts.yml deploy-docker-node.yml --vault-password-file .vault-pass

# Target a specific host
ansible-playbook -i inventories/hosts.yml deploy-docker-node.yml --vault-password-file .vault-pass -l docker_node

# Run a specific tag
ansible-playbook -i inventories/hosts.yml deploy-docker-node.yml --vault-password-file .vault-pass -t docker_node::docker
```

Tags follow the `group::task` naming convention (e.g. `docker_node::docker`, `k8s::kubeadm_init`).

## Dependencies

Collections listed in `requirements.yml`:

- `community.docker`

Install with:

```bash
ansible-galaxy collection install -r requirements.yml
```
