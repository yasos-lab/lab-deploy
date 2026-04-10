
locals {
  cloud_images = [
    {
      name   = "ubuntu-24.04-amd64.qcow2",
      type   = "import",
      url    = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img",
      verify = true
    },
    {
      name   = "debian-13-amd64.qcow2",
      type   = "import",
      url    = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2",
      verify = true
    },
    {
      name   = "alma-10-x86_64.qcow2",
      type   = "import",
      url    = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2",
      verify = true
    },
  ]
  vms = concat(var.k8s_controlplanes, var.k8s_workers, var.docker_node)
  vm_password_map = {
    "k8s"    = var.k8s_password
    "docker" = var.docker_password
  }
}

resource "proxmox_virtual_environment_download_file" "cloud_images" {
  for_each = { for f in local.cloud_images : f.name => f }

  content_type   = each.value.type
  datastore_id   = "proxmox-share"
  node_name      = "atlas"
  url            = each.value.url
  upload_timeout = 1800
  file_name      = each.value.name
  verify         = each.value.verify
}

module "vms" {
  source = "./modules/vm"

  for_each = { for vm in local.vms : vm.name => vm }

  vm_name = each.value.name
  vm_id   = each.value.id
  target_node = each.value.target_node
  vm_config = {
    cores         = each.value.config.cores
    memory        = each.value.config.memory
    os_disk       = each.value.config.os_disk
    data_disk     = try(each.value.config.data_disk, null)
    startup_order = each.value.config.startup_order
    tags          = each.value.tags
  }
  ssh_public_key = var.ssh_public_key
  lan_prefix     = var.lan_prefix
  vm_user        = var.vm_default_user
  vm_password    = try(
    local.vm_password_map[
      one([for tag in each.value.tags : tag if contains(keys(local.vm_password_map), tag)])
    ],
    var.vm_default_password
  )

  cloud_images_ready = { for k, v in proxmox_virtual_environment_download_file.cloud_images : k => v.id }
}
