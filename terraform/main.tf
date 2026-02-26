terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

module "vms" {
  source = "./modules/vm"

  for_each = var.vms

  vm_name        = each.key
  vm_config      = each.value
  target_node    = var.target_node
  template_name  = var.template_name
  ssh_public_key = var.ssh_public_key
}