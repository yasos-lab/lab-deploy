variable "vm_name" {}
variable "vm_id" {}
variable "target_node" {}
variable "vm_config" {}
variable "ssh_public_key" {}
variable "lan_prefix" {}
variable "vm_user" {}
variable "vm_password" {}
variable "os" {
    default = "proxmox-share:import/debian-13-amd64.qcow2"
}
variable "os_type" {
    default = "l26"
}

variable "cloud_images_ready" {
  description = "Pass the download file ids here to create an implicit dependency"
  type        = map(string)
}