# resource: terraform resources for deployment
# Resource: for creating pool
resource "libvirt_pool" "ubuntu" {
  name = "ubuntu-microk8s"
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

  # Resize the ubuntu cloud image to add disk space to the qcow2
  # Note: because the libvirt_pool is provisioned as system the dir will have root perms and need sudo to increase space
  provisioner "local-exec" {
    # Command if lab user can run sudo commands without a password
    command = "sudo -S qemu-img resize ${self.id} +${var.disk_size}G"
    # Uncomment command if lab user needs to enter password for sudo commands and comment command above
    # command = "echo ${var.local_root_pwd} | sudo -S qemu-img resize ${self.id} +${var.disk_size}G"
    quiet   = true
    # Continue on failure - note that cloud image disk will not be resized
    on_failure = continue
  }
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
  # Set VM name and resources
  name   = var.hostname
  vcpu   = var.cpus
  memory = var.memory

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
    volume_id = libvirt_volume.ubuntu.id
  }

  # VNC graphics for Cockpit VM terminal
  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  # Create Ansible cfg file - ansible.cfg
  provisioner "local-exec" {
    command = <<EOT
      echo "[defaults]" > ansible.cfg
      echo "host_key_checking = \"False\"" >> ansible.cfg
      echo "ansible_port = \"22\"" >> ansible.cfg
      echo "ansible_user = \"${var.username}\"" >> ansible.cfg
      echo "ansible_ssh_private_key_file = \"${var.ssh_private_key}\"" >> ansible.cfg
      echo "ansible_python_interpreter = \"/usr/bin/python3\"" >> ansible.cfg
      echo "ansible_ssh_common_args = \"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\"" >> ansible.cfg
      echo "stdout_callback = \"debug\"" >> ansible.cfg
      EOT
  }

  # Create Ansible inventory file - ansible/inventory.ini
  provisioner "local-exec" {
    command = <<EOT
      echo "[microk8s]" > ansible/inventory.ini
      echo "${libvirt_domain.domain-ubuntu.network_interface[0].addresses[0]}" >> ansible/inventory.ini
      echo "[microk8s:vars]" >> ansible/inventory.ini
      echo "ansible_user = \"${var.username}\"" >> ansible/inventory.ini
      echo "microk8s_config_path=\"/var/snap/microk8s/current/credentials/client.config\"" >> ansible/inventory.ini
      EOT
  }

  # Enable qemu_agent on VM
  qemu_agent = true
}
