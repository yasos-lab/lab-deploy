
module "k8s_cluster" {
  source = "./modules/vm"

  for_each = { for vm in concat(var.k8s_controlplanes, var.k8s_workers) : vm.name => vm }

  vm_name = each.value.name
  vm_id   = each.value.id
  vm_config = {
    cores  = each.value.cores
    memory = each.value.memory
    disk   = each.value.disk
  }
  template_name  = each.value.template
  ssh_public_key = var.ssh_public_key
  lan_prefix     = var.lan_prefix
  vm_user        = var.vm_user
  vm_password    = var.vm_password
}
