terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  vmid        = "1${var.vm_id}"
  target_node = var.target_node
  
  bios        = "ovmf"
  scsihw      = "virtio-scsi-pci"
  clone       = var.template_name
  agent       = 1

  memory = var.vm_config.memory
  cpu {
    cores = var.vm_config.cores
  }

  disk {
    slot = "ide2"
    type = "cloudinit"
    storage = "local-lvm"
  }

  disk {
    slot = "virtio0"
    type = "ignore"
  }

  disk {
    slot = "virtio1"
    type = "disk"
    size = var.vm_config.disk
    storage = "local-lvm"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    mtu    = 1
  }

  serial {
    id = 0
  }

  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password
  ipconfig0  = "ip=${var.lan_prefix}.${var.vm_id}/24,gw=${var.lan_prefix}.254"
  sshkeys = var.ssh_public_key
}