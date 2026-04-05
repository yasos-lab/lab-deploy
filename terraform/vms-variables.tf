

variable "vm_default_user" {}
variable "vm_default_password" {}

variable "k8s_controlplanes" {
  default = [
    { 
      id = 13,
      name = "k8s-controlplane-01",
      target_node = "atlas",
      tags = ["ubuntu", "k8s"],
      config = { cores = 2, memory = 4096, os_disk = 20, data_disk = 20, startup_order = 5 },
    },
    { 
      id = 23,
      name = "k8s-controlplane-02",
      target_node = "orion",
      tags = ["ubuntu", "k8s"],
      config = { cores = 2, memory = 4096, os_disk = 20, data_disk = 20, startup_order = 5 },
    },{ 
      id = 33,
      name = "k8s-controlplane-03",
      target_node = "vega",
      tags = ["ubuntu", "k8s"],
      config = { cores = 2, memory = 4096, os_disk = 20, data_disk = 20, startup_order = 5 },
    },
  ]
}

variable "k8s_workers" {
  default = [
    { 
      id = 14,
      name = "k8s-worker-01",
      target_node = "atlas",
      tags = ["ubuntu", "k8s"],
      config = { cores = 2, memory = 4096, os_disk = 20, data_disk = 20, startup_order = 6 },
    },
    { 
      id = 24,
      name = "k8s-worker-02",
      target_node = "orion",
      tags = ["ubuntu", "k8s"],
      config = { cores = 2, memory = 4096, os_disk = 20, data_disk = 20, startup_order = 6 },
    },
    { 
      id = 34,
      name = "k8s-worker-03",
      target_node = "vega",
      tags = ["ubuntu", "k8s"],
      config = { cores = 2, memory = 4096, os_disk = 20, data_disk = 20, startup_order = 6 },
    },
  ]
}

variable "docker_node" {
  default = [
    { 
      id = 19,
      name = "docker-node",
      target_node = "atlas",
      tags = ["ubuntu", "docker"],
      config = { cores = 4, memory = 8192, os_disk = 50, data_disk = 256, startup_order = 3 },
    },
  ]
}

variable "k8s_password" { sensitive = true }
variable "docker_password" { sensitive = true }
