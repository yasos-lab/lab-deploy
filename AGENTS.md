# lab-deploy

Ansible homelab deployment for yasos-lab. Deploys Docker services, a kubeadm Kubernetes cluster, DNS/DHCP/VPN (Pi-hole/PiVPN/Unbound), Caddy reverse proxy, Proxmox monitoring, and workstation setup.

## Quick start

```bash
# Install ansible, deploy workstation, setup SSH — use bootstrap.sh
./bootstrap.sh --install --ssh-config --workstation

# Or run individual playbooks directly:
ansible-playbook -i inventories/hosts.yml deploy-docker-node.yml --vault-password-file .vault-pass
```

## Ansible Vault

All secrets are in `inventories/group_vars/all/secrets.yml` (vault-encrypted AES256). The vault password file `.vault-pass` is gitignored — create it locally. Pass via `--vault-password-file .vault-pass` or `$VAULT_PASS` env var.
Never upload or put online this file `.vault-pass`.

## Inventory

- File: `inventories/hosts.yml`
- Host IPs use `{{ lan_prefix }}` variable + last octet (defined in group_vars/all or vault)
- Groups: `workstations`, `network`, `proxmox`, `docker_node`, `jellyfin_node`, `k8s` (with `k8s_controlplanes`, `k8s_workers`)
- `ansible.cfg`: `host_key_checking = False`, key at `~/.ssh/id_rsa`

## Playbooks

| Playbook | Target | Purpose |
|---|---|---|
| `deploy-workstation.yml` | `workstations` | Controller setup |
| `deploy-docker-node.yml` | `docker_node` | All Docker services |
| `deploy-jellyfin-node.yml` | `jellyfin_node` | Jellyfin LXC |
| `deploy-kubernetes.yml` | `k8s` | kubeadm cluster |
| `config-network.yml` | `network` | Pi-hole, PiVPN, Unbound, Caddy, Keepalived |
| `config-proxmox.yml` | `proxmox` | Glance agent + monitoring |
| `config-ssh.yml` | `localhost` → `all` | SSH key push |
| `debug.yml` | `docker_node` | Var debugging |

## Tags

Pattern: `group::component`. Examples: `docker_node::docker`, `docker_node::docker::services`, `k8s::system`, `network::pihole`, `workstation::packages`. Use `--tags` to run subsets.

## K8s cluster details

- kubeadm-based with numbered steps: `tasks/k8s/01-system.yml` → `08-verify-cluster.yml`
- kube-vip (`{{ lan_prefix }}.30`) for control-plane HA
- Cilium CNI v1.16.4
- Longhorn prerequisites on workers (`iscsi_tcp`, `open-iscsi`, `nfs-common`)

## Docker services

Defined in `inventories/host_vars/docker_node/containers.yml` as stacks (00-network through 06-ai). Each has services, templates, configs, and optional cron jobs. Composed via `community.docker.docker_compose_v2`.

## Architecture

- Caddy on the network node (Raspberry Pi) is the main TLS termination proxy; Traefik on the Docker node receives HTTP-only traffic behind it
- Keepalived manages VIPs for Pi-hole, PiVPN, and Caddy (failover between `raspberry` and `raspberry_backup`)
- Monitoring: node_exporter + Promtail (to Loki) + Glance agent on every node; Grafana/Loki in Docker stack
- Backups: Restic to Backblaze B2 per-service cron jobs
- Required collection: `community.docker` (in `requirements.yml`)

## Directory layout

```
inventories/          hosts.yml + group_vars/ + host_vars/
tasks/                common/ docker/ k8s/ network/ handlers/
templates/            mirrors tasks/ layout
files/                static configs (glance widgets)
miscs/                ad-hoc notes
```

One Ansible collection dependency: `community.docker`. Install with `ansible-galaxy collection install -r requirements.yml`.
