# Server Setup

## Description

This first module will document the setup process I used to build the base server that is used to automate the deployment of virtualized environments that the different technologies can be deployed to.

> :exclamation: **Note:** I'm using Ubuntu 24.04 server image to run as a headless server that I can SSH to via the command-line, but you could also use the Desktop version if your more comfortable with a Graphical interface.

## Technologies Used

- [Ubuntu Server 24.04 LTS Server](https://ubuntu.com/blog/tag/ubuntu-24-04-lts)
- [Linux KVM](https://linux-kvm.org/page/Main_Page)
- [QEMU](https://www.qemu.org/)
- [Libvirt](https://libvirt.org/apps.html)
- [Terraform](https://www.terraform.io/)


## Deployment Process

### Physical Linux Server Setup

- Follow the procedures to create the install media and do the physical install Ubuntu Server on your target hardware: [Ubuntu Server Install Guide](https://ubuntu.com/tutorials/install-ubuntu-server#1-overview)

- Login and validate you can access your server remotely

- Update your system and packages

```bash
# Update system packages
sudo apt update && sudo apt -y upgrade
```

- Validate your system supports hardware virtualization

```bash
# Verify Hardware Virtualization Support
egrep -c '(vmx|svm)' /proc/cpuinfo
```

- Install package `cpu-checker` which you can use to validate KVM is supported by your hardware

```bash
# Install cpu-checker package
sudo apt -y install cpu-checker
```

- Verify KVM can be used

```bash
# Verify KVM can be used
kvm-ok
```


### SSH Key Setup

Creating SSH keys for your user on your lab server will allow for the automated deployment and configuration of your virtual environments.

- Create an SSH key pair for your local user:

> :warning: **Note:** The documentation uses the default path and filenames for the SSH public and private keys. You can customize their names and/or locations but make note of paths and names as you would need adjust in the later commands.

```bash
ssh-keygen -t ed25519 -C "<Description of your key pair here>"
    Path: /home/<username>/.ssh/id_ed25519
```

- Add ssh public key to authorized keys, to the ssh-agent, and to your profile so they are loaded upon login

```bash
# Add your public key to the authorized keys to allow for password-less login from your local computer, IDE, etc.
cat ~/.ssh/id_ed25519.pub >> .ssh/authorized_keys

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


### KVM, QEMU, & Libvirt Setup

- Install packages needed for KVM, QEMU, & Libvirt

```bash
# Update Ubuntu and KVM packages
sudo apt update && sudo apt -y install bridge-utils libvirt-clients libvirt-daemon-system qemu-kvm virtinst guestfs-tools
```

- Setup Libvirt and QEMU to run as the local user

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
```

- Start and enable auto-start for the `libvirt-damon`

```bash
# Start libvirt-daemon and enable for autostart
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd

# Validate service started
sudo systemctl status libvirtd
```

- Validate the KVM kernel module is loaded

```bash
# Validate kernel module
lsmod |grep "kvm"
```

- Add local user account to the kvm and libvirt groups

> :warning: Groups will not show in `id` until logout/in or refresh your profile

```bash
# Add user to kvm/libvirt groups
sudo usermod -aG kvm,libvirt $USER
```

> :warning: The `default` KVM network uses a local virtualized subnet via the `virbr0` virtual interface and NAT which allows external internet access. You will not be able to connect to the virtualized systems from outside your lab server using the `default` network. Creating a bridged network will allow the VMs to obtain an IP address on your local LAN.

- Backup the existing network configuration

```bash
# Backup network config interface
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml-$(date +'%Y-%m-%d').bak
```

- Edit the `netplan` network interface YAML file

> :warning: **Note:** The network interface name may be different on your hardware and/or you may have multiple interfaces. I like to create a bridged network interface with a static IP address so I know exactly what IP address the lab server will have during boot which is handy if you are setting up a local DNS server and want to resolve the lab server by the hostname. There are other ways to define the IP address so it is consistent but that all depends on your local network setup.

```bash
# Create bridge interface
sudo vi /etc/netplan/50-cloud-init.yaml
-----
network:
  version: 2
  ethernets:
    eno1:
      dhcp4: false
      dhcp6: false

  bridges:
    br0:
      interfaces: [eno1]
      dhcp4: false
      dhcp6: false
      addresses: [<static-ip-address>/24]
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
```

- Test and apply the new network configuration

```bash
# Test and apply netplan
sudo netplan generate
sudo netplan apply

# Validate bridged interface
ip address
ip route
```

- Create bridged KVM network

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
virsh net-define ~/br0.xml
virsh net-start hostbridge
virsh net-autostart hostbridge

# Validated KVM networks
virsh net-list --all
```

- Setup folders for storage pools and set permissions to the local user

> :exclamation: **Note:** The default location for libvirt images is `/var/lib/libvirt/images/`. I am creating a directory called `terraform` in this location to hold our `storage_pools` and `vm_domains` but you can name it whatever you want

```bash
# Create folder to hold the storage pools and vm images
sudo mkdir -p /var/lib/libvirt/images/terraform

# Set permissions for libvirt default image location and the folder we just created
sudo chown $USER:kvm /var/lib/libvirt/images/
sudo chown $USER:kvm /var/lib/libvirt/images/terraform
sudo chmod 775 /var/lib/libvirt/images/terraform
```

- Create the a `default` storage pool, start, and set to auto-start on boot

```bash
# Create default pool
virsh pool-define-as default dir --target /var/lib/libvirt/images/terraform
virsh pool-build default
virsh pool-start default
virsh pool-autostart default
virsh pool-info default

# Validate KVM pool
virsh pool-list --all
```

### Terraform Installation:

- Install Linux packages (`gnupg`, `software-properties-common`, `mkisofs`):

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y gnupg software-properties-common mkisofs
```

- Install the HashiCorp GPG Key:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

- Verify the key's fingerprint:

```bash
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

- Add official HashiCorp repository

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

- Download and install the package from HashiCorp

```bash
sudo apt update && sudo apt install -y terraform
```

- Verify the install:

```bash
terraform -help plan
```

## **🎉 At this point your system is setup and ready to `virtualize`**

### [Next Step - Terraform Ubuntu Test](./Terraform_Ubuntu_Test.md)

-----


### Resources

#### Repo Table of Contents:

- [Home](./README.md)

- [Server Setup](./Server_Setup.md)

- [Terraform Ubuntu Test](./Terraform_Ubuntu_Test.md)

- [Optional Installs](./Terraform_Ubuntu_Test.md)

-----


#### GitHub Repo Information:

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

-----

