output "vms" {
  value = {
    for vm_name, vm in module.vms :
    vm_name => vm.ip_address
  }
}