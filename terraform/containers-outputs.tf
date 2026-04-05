output "lxcs" {
  value = {
    for lxc_name, c in module.lxcs :
    lxc_name => c.ip_address
  }
}