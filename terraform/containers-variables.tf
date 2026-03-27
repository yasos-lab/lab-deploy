variable "lxc_templates" {
  default = [
      { 
          name = "ubuntu-24.04-amd64.tar.zst", 
          type = "vztmpl", 
          url = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst", 
          verify = false 
      },
      { 
          name = "debian-13-amd64.tar.zst", 
          type = "vztmpl", 
          url = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst", 
          verify = false 
      },
      { 
          name = "alma-10-amd64.tar.xz", 
          type = "vztmpl", 
          url = "http://download.proxmox.com/images/system/almalinux-10-default_20250930_amd64.tar.xz", 
          verify = false 
      },
  ]  
}

variable "gitlab_runners" {
  default     = [
    { 
      name = "gitlab-runner-01", 
      id = 61, 
      target_node = "pve1"
      cores = 2, 
      memory = 1024, 
      swap = 512, 
      disk = 8 
    },
  ]
}

variable "gitlab_runner_password" {
  description = "Password for the Gitlab runner LXC password"
  sensitive   = true
}
