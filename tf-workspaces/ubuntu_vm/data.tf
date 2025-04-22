# data: templates for cloud_init, meta_data, and network_config for vm
data "template_file" "user_data" {
  template = file("${path.module}/templates/cloud_init.yaml")
  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    root_pwd       = var.root_pwd
    packages       = jsonencode(var.packages)
  }
}

data "template_file" "meta_data" {
  template = file("${path.module}/templates/meta_data.yaml")
  vars = {
    hostname = var.hostname
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/templates/network_config.yaml")
  vars = {
    dhcp        = var.dhcp
    ip_address  = var.ip_address
    subnet      = var.subnet
    gateway     = var.gateway
    nameservers = jsonencode(var.nameservers)
  }
}