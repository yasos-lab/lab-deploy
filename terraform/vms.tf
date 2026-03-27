
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
    tags          = ["Ubuntu", "K8s"]
  }
  ssh_public_key = var.ssh_public_key
  lan_prefix     = var.lan_prefix
  vm_user        = var.k8s_user
  vm_password    = var.k8s_password
}

resource "proxmox_virtual_environment_download_file" "ubuntu_24" {
  content_type = "import"
  datastore_id = "proxmox-share"
  node_name    = "pve1"
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "ubuntu-24.04-amd64.qcow2"
  upload_timeout = 1800
}

resource "proxmox_virtual_environment_download_file" "debian_13" {
  content_type = "import"
  datastore_id = "proxmox-share"
  node_name    = "pve1"
  url = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name = "debian-13-amd64.qcow2"
  upload_timeout = 1800
}

resource "proxmox_virtual_environment_download_file" "alma_10" {
  content_type = "import"
  datastore_id = "proxmox-share"
  node_name    = "pve1"
  url = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2"
  file_name = "alma-10-x86_64.qcow2"
  upload_timeout = 1800
}
