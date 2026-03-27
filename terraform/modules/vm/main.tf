terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

locals {
  os_map = {
    Ubuntu = "proxmox-share:import/ubuntu-24.04-amd64.qcow2"
    Debian = "proxmox-share:import/debian-13-amd64.qcow2"
    Alma   = "alma-10-x86_64.qcow2"
  }

  os = try(
    local.os_map[
      one([for tag in var.vm_config.tags : tag if contains(keys(local.os_map), tag)])
    ],
    var.os
  )
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  description = "Managed by Terraform"
  tags        = var.vm_config.tags

  node_name   = var.target_node
  vm_id       = "1${var.vm_id}"

  agent {
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  startup {
    order      = var.vm_config.startup_order
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores        = 2
    type         = "x86-64-v2-AES"  # recommended for modern CPUs
  }

  memory {
    dedicated = var.vm_config.memory
    floating  = var.vm_config.memory # set equal to dedicated to enable ballooning
  }

  disk {
    interface    = "scsi0"
    size         = 10
    import_from  = local.os
  }

  disk {
    interface    = "scsi1"
    size         = var.vm_config.disk
  }

  initialization {
    ip_config {
      ipv4 {
        gateway = "${var.lan_prefix}.254"
        address = "${var.lan_prefix}.${var.vm_id}/24"
      }
    }
    user_account {
      keys     = var.ssh_public_key
      password = var.vm_password
      username = var.vm_user
    }
  }

  keyboard_layout = "fr"

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  # tpm_state {
  #   version = "v2.0"
  # }

  serial_device {}

  # virtiofs {
  #   mapping = "data_share"
  #   cache = "always"
  #   direct_io = true
  # }
}
