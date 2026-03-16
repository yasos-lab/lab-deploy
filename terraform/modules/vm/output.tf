output "ip_address" {
  value = "${var.lan_prefix}.${var.vm_id}/24"
}