# Project

Ansible repo for homelab infrastructure (Proxmox, K8s, Docker, network, workstation).

## Key commands

```bash
# Setup (install Ansible)
./bootstrap.sh --install

# SSH config + connectivity check
./bootstrap.sh --ssh-config

# Workstation setup
./bootstrap.sh --workstation

# Run a single playbook directly
ansible-playbook -i inventories/hosts.yml deploy-docker-node.yml --vault-password-file .vault-pass

# Target a single host or tag
ansible-playbook -i inventories/hosts.yml deploy-docker-node.yml --vault-password-file .vault-pass -l docker_node -t docker_node::docker
```

## Vault & secrets

- Secrets live in `inventories/group_vars/all/secrets.yml` (Ansible Vault encrypted).
- Vault password file: `.vault-pass` (gitignored). Pass `--vault-password-file .vault-pass` when running playbooks manually.
- **Never read or display `.vault-pass` or `secrets.yml` contents.**

## Inventory structure

- `inventories/hosts.yml` — all hosts (docker_node, jellyfin_node, raspberry, pve, k8s controlplanes/workers, workstation).
- `inventories/group_vars/` — variables per group (`all/`, `k8s/`, `network/`, `proxmox/`, `workstations/`).
- `all/main.yml` — shared variables (packages, paths, versions).
- `all/docker.yml`, `all/monitoring.yml` — domain-specific vars.

## Playbooks (top-level)

| Playbook | Target group |
|---|---|
| `deploy-docker-node.yml` | `docker_node` |
| `deploy-jellyfin-node.yml` | `jellyfin_node` |
| `deploy-kubernetes.yml` | `k8s` |
| `deploy-workstation.yml` | `workstations` |
| `config-ssh.yml` | `all` |
| `config-network.yml` | `network` |
| `config-proxmox.yml` | `proxmox` |
| `debug.yml` | `all` (debug) |

## Task organization

- `tasks/common/` — shared tasks (packages, repositories, filesystem, shell, rclone, restic, systemd services).
- `tasks/docker/` — Docker install + services.
- `tasks/k8s/` — numbered sequence (`01-system` through `05-kubeadm-init`).
- `tasks/network/` — network/router tasks.
- `tasks/handlers/` — handlers (reused across playbooks).
- `templates/` and `files/` — Jinja2 templates and static files referenced by tasks.

## Constraints

- Do not read files listed in `.gitignore` (especially `.vault-pass`).
- Do not commit `.vault-pass` or decrypt vault-encrypted files in output.
- Playbooks use `ansible.builtin.import_tasks` (static include); tags follow `group::task` naming (e.g. `docker_node::docker`).
- K8s tasks are ordered by number; filesystem and kube-vip tasks are conditionally applied per host group.
