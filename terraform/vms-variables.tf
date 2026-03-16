variable "k8s_controlplanes" {
  default     = [
    { name = "k8s-controlplane-01", id = 51, template = "ubuntu-server-24.04", cores = 2, memory = 4096, disk = "20G" },
    { name = "k8s-controlplane-02", id = 52, template = "ubuntu-server-24.04", cores = 2, memory = 4096, disk = "20G" },
    { name = "k8s-controlplane-03", id = 53, template = "ubuntu-server-24.04", cores = 2, memory = 4096, disk = "20G" },
  ]
}

variable "k8s_workers" {
  default     = [
    { name = "k8s-worker-01", id = 54, template = "ubuntu-server-24.04", cores = 2, memory = 4096, disk = "20G" },
    { name = "k8s-worker-02", id = 55, template = "ubuntu-server-24.04", cores = 2, memory = 4096, disk = "20G" },
  ]
}

variable "vm_user" {
  description = "Username to create on VMs"
  default     = ""
}
variable "vm_password" {
  description = "Password for the VM user"
  sensitive   = true
  default     = ""
}