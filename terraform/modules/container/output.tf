output "ip_address" {
  value = "${var.lan_prefix}.${var.lxc_id}/24"
}