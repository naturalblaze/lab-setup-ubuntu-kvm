# terraform: https://developer.hashicorp.com/terraform/language/block/terraform#terraform
# Terraform provider for libvirt: https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

# provider: https://developer.hashicorp.com/terraform/language/block/provider
# Configure the Libvirt provider for local QEMU system resources
provider "libvirt" {
  uri = "qemu:///system"
}
