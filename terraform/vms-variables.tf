
variable "cloud_images" {
  default = [
      { 
          name = "ubuntu-24.04-amd64.qcow2", 
          type = "import", 
          url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img", 
          verify = true 
      },
      { 
          name = "debian-13-amd64.qcow2", 
          type = "import", 
          url = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2", 
          verify = true 
      },
      { 
          name = "alma-10-x86_64.qcow2", 
          type = "import", 
          url = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2", 
          verify = true 
      },
  ]
}

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