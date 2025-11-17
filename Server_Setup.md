# Server Setup

This first module will document the setup process I used to build the base server that is used to automate the deployment of virtualized environments that the different technologies can be deployed to.

## Table of Contents

* [Server Technologies Used](./Server_Setup.md#server-technologies-used)

* [Physical Linux Server Setup](./Server_Setup.md#physical-linux-server-setup)

* [SSH Key Setup](./Server_Setup.md#ssh-key-setup)

* [KVM, QEMU, & Libvirt Setup](./Server_Setup.md#kvm-qemu-and-libvirt-setup)

* [Terraform Installation](./Server_Setup.md#terraform-installation)

## Server Technologies Used

* [Ubuntu Server 24.04 LTS Server](https://ubuntu.com/blog/tag/ubuntu-24-04-lts)

* [Linux KVM](https://linux-kvm.org/page/Main_Page)

* [QEMU](https://www.qemu.org/)

* [Libvirt](https://libvirt.org/apps.html)

* [Terraform](https://www.terraform.io/)

## Physical Linux Server Setup

* Follow the procedures to create the install media and do the physical install Ubuntu Server on your target hardware: [Ubuntu Server Install Guide](https://ubuntu.com/tutorials/install-ubuntu-server#1-overview)

> :bulb: **Note:** I prefer to setup a static IP address for my server so I know exactly where my server will always be after reboots but you could also use DHCP reservations on your router if you prefer.

* Login and validate you can access your server remotely

* Update your system and packages

```bash
# Update system packages
sudo apt update && sudo apt -y upgrade
```

* Validate your system supports hardware virtualization

```bash
# Verify Hardware Virtualization Support
egrep -c '(vmx|svm)' /proc/cpuinfo
```

* Install package `cpu-checker` which you can use to validate KVM is supported by your hardware

```bash
# Install cpu-checker package
sudo apt -y install cpu-checker
```

* Verify KVM can be used

```bash
# Verify KVM can be used
kvm-ok
```

> :warning: **Note:** It is critical your system support virtualization and kvm. If either of those checks fail you will want to verify your system supports virtualization and it is enabled. Some systems will have virtualization disabled by default in the bios so you may need to enable it there, but you will have to do some googling based on your hardware setup.

### SSH Key Setup

Creating SSH keys for your user on your lab server will allow for the automated deployment and configuration of your virtual environments. It is up to you if you want to password protect your SSH key but since this is a lab setup you can just hit enter twice to bypass the need of a password. If you already have SSH keys generated you can just copy those over to the lab server as well to the `~/.ssh` folder of the users home. Some additional documentation can be found in [GiHub Docs - Generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

* Create an SSH key pair for your local user

> :exclamation: **Note:** The documentation uses the default path and filenames for the SSH public and private keys. You can customize their names and/or locations but make note of paths and names as you would need adjust in the later commands.

```bash
ssh-keygen -t ed25519 -C "<Description of your key pair here>"
    Path: /home/<username>/.ssh/id_ed25519
```

* Load the ssh-agent and add your private key. Add it to your profile so they are loaded upon login

```bash
# Add the private key to the ssh-agent
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519

# Add the private key to your user .profile so it is loaded at login to the lab server
cat >> ~/.profile << 'EOF'

# Load the SSH private key into the ssh-agent at login
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
EOF
```

* Optional: Add your public key to the authorized keys if you want to use the same private key from your local computer, IDE, etc. to connect to the lab. You could also create separate keys for those systems and add them to the lab server with `ssh-copy-id <USER-NAME>@<LAB-IP-ADDRESS>`

```bash
# Add your public key to the authorized keys to allow for access to the lab system
cat ~/.ssh/id_ed25519.pub >> .ssh/authorized_keys
```

* Disable SSH host checking and disable storing server keys

> :stop_sign: **Note: DOING THIS IS A TERRIBLE SECURITY PRACTICE!** I would never recommend doing this but since this is a lab device and we will be creating and destroying VM's most likely with the same server names and IP addresses this will make sure the server keys are not stored when connecting which will cause a connection error if that servers fingerprint changes.

```bash
cat >> ~/.ssh/config << 'EOF'
Host *
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null
EOF
```

> Alternatively you can just remove the old host key whenever a host is re-created.
>
> ```bash
> ssh-keygen -f '~/.ssh/known_hosts' -R <server-name or ip-address>
> ```

* Setup passwordless sudo commands

```bash
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
```

### KVM, QEMU, and Libvirt Setup

* Install packages needed for KVM, QEMU, & Libvirt

```bash
# Update Ubuntu and KVM packages
sudo apt update && sudo apt -y install bridge-utils libvirt-clients libvirt-daemon-system qemu-kvm virtinst guestfs-tools
```

* Setup Libvirt and QEMU to run as the local user

> :exclamation: **Note:** This will help prevent permission issues with files that are created. The `security_drive` definition will prevent AppArmor from blocking libvirt from creating system resources.

```bash
# Backup qemu.conf
sudo cp /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf-$(date +'%Y-%m-%d').bak

# Uncomment or add the below lines qemu.conf settings for file permissions
# You can use whatever editor you prefer, I am most familiar with vi
sudo vi /etc/libvirt/qemu.conf
-----
user = "<username>"
group = "kvm"
security_driver = "none"
-----
esc :wq
```

* Start and enable auto-start for the `libvirt-damon`

```bash
# Start libvirt-daemon and enable for autostart
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd

# Validate service started
sudo systemctl status libvirtd
```

* Validate the KVM kernel module is loaded

```bash
# Validate kernel module
lsmod |grep "kvm"
```

* Add local user account to the kvm and libvirt groups

> :warning: Groups will not show in `id` until logout/in or refresh your profile `. ~/.profile`

```bash
# Add user to kvm/libvirt groups
sudo usermod -aG kvm,libvirt $USER

# Reload your profile
. ~/.profile
```

> :bulb: **Note:** The `default` KVM network uses a local virtualized subnet via the `virbr0` virtual interface and NAT which allows external internet access. You will not be able to connect to the virtualized systems from outside your lab server using the `default` network. Creating a bridged network will allow the VMs to obtain an IP address on your local LAN. More information can be read at [NetworkConnectionBridge](https://help.ubuntu.com/community/NetworkConnectionBridge).

* Backup the existing network configuration

```bash
# Backup network config interface
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml-$(date +'%Y-%m-%d').bak
```

* Edit the `netplan` network interface YAML file to create a bridged network interface `br0`. This is also convenient if your system has multiple network interfaces you can combine them into one bridged interface for speed and resiliency. Make sure to change the `<ethernet-interface>`, `<static-ip-address>`, `<cider-subnet>`, `<gateway-ip-address>`, `<dns-nameserver1>`, and `<dns-nameserver2>` fields to reflect your hardware and network settings.

```bash
# Create bridge interface
sudo vi /etc/netplan/50-cloud-init.yaml
-----
network:
  version: 2
  ethernets:
    <ethernet-interface>:
      dhcp4: false
      dhcp6: false

  bridges:
    br0:
      interfaces: [<ethernet-interface>]
      dhcp4: false
      dhcp6: false
      addresses: [<static-ip-address>/<cider-subnet>]
      routes:
        - to: default
          via: <gateway-ip-address>
          metric: 100
      nameservers:
        addresses: [<dns-nameserver1>, <dns-nameserver2>]
      mtu: 1500
      parameters:
        stp: true
        forward-delay: 4
-----
esc :wq
```

* Test and apply the new network configuration

```bash
# Test and apply netplan
sudo netplan generate
sudo netplan apply

# Validate bridged interface
ip address
ip route
```

* Create bridged KVM network

```bash
# Create file for KVM bridged network
cat > ~/br0.xml << EOF
<network>
  <name>hostbridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

# Apply the bridged network, start it, and set it to auto-start
sudo virsh net-define ~/br0.xml
sudo virsh net-start hostbridge
sudo virsh net-autostart hostbridge

# Validated KVM networks
sudo virsh net-list --all
```

* Setup folders for storage pools and set permissions to the local user. The default location for libvirt images is `/var/lib/libvirt/images/`. I am creating a directory called `terraform` in this location to hold our `storage_pools` and `vm_domains` but you can name it whatever you want.

```bash
# Create folder to hold the storage pools and vm images
sudo mkdir -p /var/lib/libvirt/images/terraform

# Set permissions for libvirt default image location and the folder we just created
sudo chown $USER:kvm /var/lib/libvirt/images/
sudo chown $USER:kvm /var/lib/libvirt/images/terraform
sudo chmod 775 /var/lib/libvirt/images/terraform
```

* Create the a `default` storage pool, start, and set to auto-start on boot

> :bulb: **Note:** You could run these commands without sudo but then the storage pool would be created as a `session` resource instead of a `system` resource. You can read more about the difference between the two resources with Libvirt ([qemu:///system or qemu:///session](https://wiki.libvirt.org/FAQ.html#what-is-the-difference-between-qemu-system-and-qemu-session-which-one-should-i-use)). I'm going to use system so that when we deploy our resources with terraform we won't run into any permisison issues due to possible different users.

```bash
# Create default and pool
sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
sudo virsh pool-build default
sudo virsh pool-start default
sudo virsh pool-autostart default
sudo virsh pool-info default
# Create terraform pool
sudo virsh pool-define-as terraform dir --target /var/lib/libvirt/images/terraform
sudo virsh pool-build terraform
sudo virsh pool-start terraform
sudo virsh pool-autostart terraform
sudo virsh pool-info terraform

# Validate KVM pool
sudo virsh pool-list --all
```

### Terraform Installation

Terraform is an open-source Infrastructure as Code (IaC) tool that allows users to define and provision infrastructure using a declarative language in configuration files. It enables safe and efficient management of both cloud and on-premises resources, including compute, storage, networking, and high-level components like DNS entries. By writing code to describe the desired state of their infrastructure, users can automate provisioning, manage its lifecycle, and ensure consistency and scalability. I'm going to use it to easily spin up different infrastructure environments for our lab. [Terraform install documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

* Install Linux packages (`gnupg`, `software-properties-common`, `mkisofs`):

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y gnupg software-properties-common mkisofs
```

* Install the HashiCorp GPG Key:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

* Verify the key's fingerprint:

```bash
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

* Add official HashiCorp repository

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

* Download and install the package from HashiCorp

```bash
sudo apt update && sudo apt install -y terraform
```

* Verify the install:

```bash
terraform -help plan
```

* Enable tab completion

```bash
# Make sure bashrc file exists
touch ~/.bashrc

# Install terraform autocomplete
terraform -install-autocomplete

# Restart your shell
reset; exec bash
```

## **🎉 At this point your system is setup and ready to `virtualize` 🎉**

> Check out the [Optional Installs](./Optional_Installs.md) for some additional setups for Cockpit, GitHub, VSCode and Ansible to help with your IaC learning.

### [Next Project - Deploy Ubuntu VM with Terraform](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md)

---

### Resources

#### Repo Table of Contents:

* [Home](./README.md)

* [Server Setup](./Server_Setup.md)

* [Optional Installs](./Optional_Installs.md)

* Terraform Deployments:

    * [Ubuntu VM with Terraform](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md) - Deploy an Ubuntu Linux Server VM.

    * [Ubuntu VM K8S Single Node MicroK8S with Terraform](./tf-workspaces/ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md) - Deploy an Ubuntu Linux Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.

---

#### GitHub Repo Information:

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

---
