# output: terraform output blocks

output "vm_ip_address" {
  value       = "\nVM Login: ssh ${var.username}@${libvirt_domain.domain-dnsmasq.network_interface.0.addresses.0}"
  description = "Ubuntu VM IP address"
  sensitive   = false
}
