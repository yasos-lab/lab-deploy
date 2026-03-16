output "k8s_ips" {
  value = {
    for vm_name, vm in module.k8s_cluster :
    vm_name => vm.ip_address
  }
}