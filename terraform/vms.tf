
resource "proxmox_virtual_environment_download_file" "cloud_images" {
  for_each = { for f in var.cloud_images : f.name => f }

  content_type   = each.value.type
  datastore_id   = "proxmox-share"
  node_name      = "pve1"
  url            = each.value.url
  upload_timeout = 1800
  file_name      = each.value.name
  verify         = each.value.verify
}

module "k8s_cluster" {
  source = "./modules/vm"

  for_each = { for vm in concat(var.k8s_controlplanes, var.k8s_workers) : vm.name => vm }

  vm_name = each.value.name
  vm_id   = each.value.id
  target_node = each.value.target_node
  vm_config = {
    cores         = each.value.cores
    memory        = each.value.memory
    disk          = each.value.disk
    startup_order = each.value.startup_order
    tags          = ["ubuntu", "k8s"]
  }
  ssh_public_key = var.ssh_public_key
  lan_prefix     = var.lan_prefix
  vm_user        = var.k8s_user
  vm_password    = var.k8s_password

  cloud_images_ready = { for k, v in proxmox_virtual_environment_download_file.cloud_images : k => v.id }
}
