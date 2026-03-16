variable "vm_name" {}
variable "vm_id" {}
variable "vm_config" {}
variable "target_node" {
    default = "proxmox"
}
variable "template_name" {}
variable "ssh_public_key" {}
variable "lan_prefix" {}
variable "vm_user" {}
variable "vm_password" {}