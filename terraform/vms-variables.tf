variable "k8s_controlplanes" {
  default     = [
    { name = "k8s-controlplane-01", id = 51, target_node = "pve1", cores = 2, memory = 4096, disk = 20, startup_order = 5 },
    { name = "k8s-controlplane-02", id = 52, target_node = "pve1", cores = 2, memory = 4096, disk = 20, startup_order = 5},
    { name = "k8s-controlplane-03", id = 53, target_node = "pve1", cores = 2, memory = 4096, disk = 20, startup_order = 5},
  ]
}

variable "k8s_workers" {
  default     = [
    { name = "k8s-worker-01", id = 54, target_node = "pve1", cores = 2, memory = 4096, disk = 20, startup_order = 6},
    { name = "k8s-worker-02", id = 55, target_node = "pve1", cores = 2, memory = 4096, disk = 20, startup_order = 6},
  ]
}

variable "k8s_user" {
  description = "Username to create on VMs"
  default     = ""
}
variable "k8s_password" {
  description = "Password for the VM user"
  sensitive   = true
  default     = ""
}