locals {
    lxc_templates = [
        { 
            name = "ubuntu-24.04-amd64.tar.zst", 
            type = "vztmpl", 
            url = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst", 
            verify = false 
        },
        { 
            name = "debian-13-amd64.tar.zst", 
            type = "vztmpl", 
            url = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst", 
            verify = false 
        },
        { 
            name = "alma-10-amd64.tar.xz", 
            type = "vztmpl", 
            url = "http://download.proxmox.com/images/system/almalinux-10-default_20250930_amd64.tar.xz", 
            verify = false 
        },
    ]
    containes = concat(var.gitlab_runners)
    container_password_map = {
      "gitlab_runner"    = var.gitlab_runner_password
    }
}

# Created once, shared across all VMs
resource "proxmox_virtual_environment_download_file" "lxc_templates" {
  for_each = { for f in local.lxc_templates : f.name => f }

  content_type   = each.value.type
  datastore_id   = "proxmox-share"
  node_name      = "atlas"
  url            = each.value.url
  upload_timeout = 1800
  file_name      = each.value.name
  verify         = each.value.verify
}

module "lxcs" {
  source = "./modules/container"

  for_each = { for lxc in local.containes : lxc.name => lxc }

  lxc_name = each.value.name
  lxc_id   = each.value.id
  target_node = each.value.target_node
  lxc_config = {
    cores  = each.value.cores
    memory = each.value.memory
    swap   = each.value.swap
    disk   = each.value.disk
    tags   = ["ubuntu", "cicd", "gitlab_runner"]
  }
  ssh_public_key = var.ssh_public_key
  lan_prefix     = var.lan_prefix
  lxc_password   = try(
    local.container_password_map[
      one([for tag in ["ubuntu", "cicd", "gitlab_runner"] : tag if contains(keys(local.container_password_map), tag)])
    ],
    var.vm_default_password
  )

  lxc_templates_ready = { for k, v in proxmox_virtual_environment_download_file.lxc_templates : k => v.id }
}








