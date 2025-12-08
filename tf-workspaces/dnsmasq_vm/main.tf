# main/resource: https://developer.hashicorp.com/terraform/language/block/resource

# Resource: for creating pool
resource "libvirt_pool" "dnsmasq" {
  name = var.libvirt_pool_name
  type = "dir"
  target {
    path = var.libvirt_pool_path
  }
}

# Resource: for ubuntu cloud image volume
resource "libvirt_volume" "dnsmasq" {
  name   = "ubuntu-qcow2"
  pool   = libvirt_pool.dnsmasq.name
  source = var.img_url
  format = "qcow2"

  # Resize the ubuntu cloud image to add disk space to the qcow2
  # Note: because the libvirt_pool is provisioned as system the dir will have root perms and need sudo to increase space
  provisioner "local-exec" {
    # Conditional command expand disk
    command = var.local_root_pwd == "" ? "sudo -S qemu-img resize ${self.id} +${var.disk_size}G" : "echo ${var.local_root_pwd} | sudo -S qemu-img resize ${self.id} +${var.disk_size}G"
    # No output for command
    quiet = true
    # Continue on failure - note that cloud image disk will not be resized
    on_failure = continue
  }
}

# Resource: for cloud_init iso disk for vm configuration
# For more information check:
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = templatefile(
    "${path.module}/templates/cloud_init.tftpl",
    {
      hostname       = var.hostname,
      username       = var.username,
      ssh_public_key = file(var.ssh_public_key),
      root_pwd       = var.root_pwd,
      user_pwd       = var.user_pwd,
      packages       = jsonencode(var.packages),
      ip_address     = var.ip_address,
      nameservers    = var.nameservers,
      domain_name    = var.domain_name,
      domain_hosts   = var.domain_hosts,
    }
  )
  meta_data = templatefile(
    "${path.module}/templates/meta_data.tftpl",
    {
      hostname = var.hostname,
    }
  )
  network_config = templatefile(
    "${path.module}/templates/network_config.tftpl",
    {
      ip_address  = var.ip_address,
      subnet      = var.subnet_cidr,
      gateway     = var.gateway,
      nameservers = var.nameservers,
      domain_name = var.domain_name,
    }
  )
  pool = libvirt_pool.dnsmasq.name
}

# Resource: for VM domain creation
resource "libvirt_domain" "domain-dnsmasq" {
  # Set VM name and resources
  name      = var.hostname
  type      = "kvm"
  vcpu      = var.cpus
  memory    = var.memory
  autostart = true

  # Set cloud-init
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # Set network interface
  network_interface {
    network_name   = var.network
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # Set disk volume
  disk {
    volume_id = libvirt_volume.dnsmasq.id
  }

  # VNC graphics for Cockpit VM terminal
  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  # Enable qemu_agent on VM
  qemu_agent = true
}
