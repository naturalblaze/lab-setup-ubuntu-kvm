# provider: terraform config and libvirt provider
# Terraform provider for libvirt: https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

# Configure the Libvirt provider for local QEMU system
provider "libvirt" {
  uri = "qemu:///system"
}
