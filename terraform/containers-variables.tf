
variable "gitlab_runners" {
  default     = [
    { 
      name = "gitlab-runner-01", 
      id = 61, 
      target_node = "vega"
      cores = 2, 
      memory = 1024, 
      swap = 512, 
      disk = 8 
    },
  ]
}

variable "gitlab_runner_password" { sensitive   = true }
