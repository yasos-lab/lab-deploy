# Terraform

Provisions VMs and LXC containers on Proxmox.

## Prerequisites

### Local Tools

- [Terraform](https://www.terraform.io/) >= 1.5
- [SOPS](https://github.com/getsops/sops) >= 3.0
- [age](https://github.com/FiloSottile/age)

### Proxmox Configuration

Before running Terraform, ensure the following is configured in Proxmox:

- **API Token**: Create a token with PVEAuditor, PVEDatastoreUser, VMAdmin privileges
- **VM Template**: Cloud-init template with SSH key configured
- **Network Bridge**: vmbr0 (or custom bridge) for VM networking
- **Storage**: Sufficient space on local-lvm for your VMs/LXCs

## Modules

### vm/

Creates QEMU virtual machines from a template with cloud-init configuration.

| Variable | Type | Description |
|----------|------|-------------|
| `vm_name` | string | Name of the VM |
| `vm_id` | number | Last octet of the IP (e.g., 51 for 10.0.0.51) |
| `vm_config` | object | Configuration with `cores`, `memory`, `disk` |
| `template_name` | string | Name of the VM template to clone |
| `ssh_public_key` | string | SSH public key for cloud-init |
| `lan_prefix` | string | LAN network prefix (e.g., `10.0.0`) |
| `vm_user` | string | Cloud-init username |
| `vm_password` | string | Cloud-init password |
| `target_node` | string | Proxmox node (default: `proxmox`) |

| Output | Description |
|--------|-------------|
| `ip_address` | Assigned IP address |

### lxc/

Creates LXC containers (currently under development).

## Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `pm_api_url` | Proxmox API URL | Yes |
| `pm_api_token_id` | Proxmox token ID | Yes |
| `pm_api_token_secret` | Proxmox token secret | Yes |

## Secrets

Sensitive variables are stored encrypted using [SOPS](https://github.com/getsops/sops) with age encryption.

### Configuration

The SOPS configuration is defined in the root `.sops.yaml` file.

### Encrypted Files

| File | Description |
|------|-------------|
| `backend.hcl` | S3 backend credentials for state storage |
| `terraform.tfvars` | Proxmox credentials and configuration |

### Usage

```bash
# Edit encrypted file
sops terraform.tfvars

# Decrypt and show content
sops decrypt terraform.tfvars

# Apply with decrypted vars
sops exec-env terraform.tfvars 'terraform plan'
```

### Requirements

- Age recipient key: `age1hktcxjj6qj6sw4rzqa7lsfxj7a7985m0muwqrm29jt6a59xxke8q5vj8jv`

## Backend

Terraform state is stored remotely using S3-compatible storage. The backend configuration is encrypted in `backend.hcl` using SOPS.

```bash
# Decrypt and initialize
sops exec-env backend.hcl 'terraform init'

# Pull latest state
sops exec-env backend.hcl 'terraform pull'
```

## Usage

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

## Example Usage

```hcl
module "my_vm" {
  source = "./modules/vm"

  vm_name      = "my-server"
  vm_id        = 100
  template_name = "ubuntu-2204-template"
  
  vm_config = {
    cores  = 2
    memory = 4096
    disk   = "20G"
  }

  ssh_public_key = file("~/.ssh/id_rsa.pub")
  lan_prefix     = "10.0.0"
  vm_user        = "admin"
  vm_password    = "changeme"
}
```
