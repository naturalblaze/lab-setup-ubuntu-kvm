# Can be used for debugging what the cloud-init data looks like WARNING this will show sensitive data
# output "user_data" {
#   value = "\n${data.template_file.user_data.rendered}"
# }

# output "network_config" {
#   value = "\n${data.template_file.network_config.rendered}"
# }

# output "meta_data" {
#   value = "\n${data.template_file.meta_data.rendered}"
# }

output "vm_ip_address" {
  value = libvirt_domain.domain-ubuntu.network_interface.0.addresses.0
}