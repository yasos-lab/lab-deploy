variable "lxc_name" {}
variable "lxc_id" {}
variable "lxc_config" {}
variable "target_node" {}

variable "lxc_password" {}
variable "ssh_public_key" {}
variable "lan_prefix" {}

variable "os" {
    default = "proxmox-share:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
}

variable "lxc_templates_ready" {
  description = "Pass the download file ids here to create an implicit dependency"
  type        = map(string)  # receives the ids from the download resources
}
