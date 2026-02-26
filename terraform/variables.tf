variable "pm_api_url" {}
variable "pm_api_token_id" {}
variable "pm_api_token_secret" {}

variable "target_node" {}
variable "template_name" {}

variable "ssh_public_key" {}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    ip      = string
    cores   = number
    memory  = number
    disk    = string
  }))
}