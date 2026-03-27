terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

locals {
  os_map = {
    ubuntu = "proxmox-share:vztmpl/ubuntu-24.04-amd64.tar.zst"
    debian = "proxmox-share:vztmpl/debian-13-amd64.tar.zst"
    alma   = "proxmox-share:vztmpl/alma-10-amd64.tar.xz"
  }

  os = try(
    local.os_map[
      one([for tag in var.lxc_config.tags : tag if contains(keys(local.os_map), tag)])
    ],
    var.os
  )
}

resource "proxmox_virtual_environment_container" "containers" {
  depends_on = [
    var.lxc_templates_ready
  ]
  
  description = "Managed by Terraform"

  node_name = var.target_node
  vm_id     = "1${var.lxc_id}"
  tags      = var.lxc_config.tags

  # newer linux distributions require unprivileged user namespaces
  unprivileged = true
  features {
    nesting = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  operating_system {
    template_file_id = local.os
    type             = var.lxc_config.tags[0]
  }
  
  cpu {
    cores = var.lxc_config.cores
  }

  memory {
    dedicated = var.lxc_config.memory
    swap = var.lxc_config.swap
  }

  disk {
    datastore_id = "local-lvm"
    size         = var.lxc_config.disk
  }

  initialization {
    hostname = var.lxc_name

    ip_config {
      ipv4 {
        gateway = "${var.lan_prefix}.254"
        address = "${var.lan_prefix}.${var.lxc_id}/24"
      }
    }
    user_account {
      keys     = var.ssh_public_key
      password = var.lxc_password
    }
  }

  network_interface {
    name = "veth0"
  }

  # mount_point {
  #   # bind mount, *requires* root@pam authentication
  #   volume = "/mnt/bindmounts/shared"
  #   path   = "/mnt/shared"
  # }

  # mount_point {
  #   # volume mount, a new volume will be created by PVE
  #   volume = "local-lvm"
  #   size   = "10G"
  #   path   = "/mnt/volume"
  # }

  # mount_point {
  #   # volume mount, an existing volume will be mounted
  #   volume = "local-lvm:subvol-108-disk-101"
  #   size   = "10G"
  #   path   = "/mnt/data"
  # }

  # To reference a mount point volume from another resource, use path_in_datastore:
  # mount_point {
  #   volume = other_container.mount_point[0].path_in_datastore
  #   size   = "10G"
  #   path   = "/mnt/shared"
  # }
}

