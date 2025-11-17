# output: terraform output blocks

output "user_data" {
  value       = "\n${data.template_file.user_data.rendered}"
  description = "Cloud-Init packages, commands, and user data configs"
  sensitive   = true
}

output "network_config" {
  value       = "\n${data.template_file.network_config.rendered}"
  description = "Cloud-Init network interface config"
  sensitive   = false
}
output "meta_data" {
  value       = "\n${data.template_file.meta_data.rendered}"
  description = "Cloud-Init meta data config"
  sensitive   = false
}

output "vm_ip_address" {
  value       = "\nVM Login: ssh ${var.username}@${libvirt_domain.domain-ubuntu.network_interface.0.addresses.0}"
  description = "Ubuntu VM IP address"
  sensitive   = false
}
