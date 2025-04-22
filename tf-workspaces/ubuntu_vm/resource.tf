# Resource: for creating ubuntu-test pool
resource "libvirt_pool" "ubuntu" {
  name = "ubuntu-test"
  type = "dir"
  target {
    path = var.libvirt_pool_path
  }
}

# Resource: for ubuntu cloud image volume
resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu-qcow2"
  pool   = libvirt_pool.ubuntu.name
  source = var.ubuntu_img_url
  format = "qcow2"
}

# Resource: for cloud_init iso disk for vm configuration
# For more information check:
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  meta_data      = data.template_file.meta_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.ubuntu.name
}

# Resource: for VM domain creation
resource "libvirt_domain" "domain-ubuntu" {
  name   = var.hostname
  vcpu   = var.cpus
  memory = var.memory

  cloudinit = libvirt_cloudinit_disk.commoninit.id

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

  disk {
    volume_id = libvirt_volume.ubuntu.id
  }

  # VNC graphics for Cockpit VM terminal
  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  qemu_agent = true
}
