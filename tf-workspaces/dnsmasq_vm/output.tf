# output: https://developer.hashicorp.com/terraform/language/block/output
output "vm_ip_address" {
  value       = "\nVM Login: ssh ${var.username}@${libvirt_domain.domain-dnsmasq.network_interface.0.addresses.0}"
  description = "Ubuntu VM IP address"
  sensitive   = false
}
