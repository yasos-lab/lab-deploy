resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template_name

  cores  = var.vm_config.cores
  memory = var.vm_config.memory

  disk {
    size    = var.vm_config.disk
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type   = "cloud-init"
  ipconfig0 = "ip=${var.vm_config.ip},gw=${var.lan_prefix}.254"

  sshkeys = var.ssh_public_key

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update",
  #     "sudo apt install -y qemu-guest-agent",
  #     "sudo systemctl enable qemu-guest-agent",
  #     "sudo systemctl start qemu-guest-agent"
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("~/.ssh/id_rsa")
  #     host        = split("/", var.vm_config.ip)[0]
  #   }
  # }
}