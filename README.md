# Lab Setup

## Ubuntu Lab Server with KVM, Libvirt, QEMU, Terraform and Ansible

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

## Description

I wanted to create a lab environment where I could easily deploy and destroy virtualized technologies using IaC tools for learning, testing, and development purposes. I have a MiniPC I used for a headless base server running Ubuntu 24.04 Server with KVM, QEMU, and Libvirt to support virtualization. You could use many different Linux distributions or even desktop flavors, but we are going to focus on Linux.

### [Next Project - Server Setup](./Server_Setup.md)

---

## Resources

### Repo Table of Contents:

* [Home](./README.md)

* [Server Setup](./Server_Setup.md)

* [Optional Installs](./Optional_Installs.md)

* Terraform Deployments:

    * [Ubuntu VM with Terraform](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md) - Deploy an Ubuntu Linux Server VM.

    * [Ubuntu VM K8S Single Node MicroK8S with Terraform](./tf-workspaces/ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md) - Deploy an Ubuntu Linux Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.

---

### Repo Structure:

```text
lab-setup-ubuntu-kvm/
├── LICENSE
├── Optional_Installs.md
├── README.md
├── Server_Setup.md
└── tf-workspaces
    ├── ubuntu_vm
    │   ├── data.tf
    │   ├── main.tf
    │   ├── output.tf
    │   ├── provider.tf
    │   ├── templates
    │   │   ├── cloud_init.tftpl
    │   │   ├── meta_data.tftpl
    │   │   └── network_config.tftpl
    │   ├── terraform.tfstate
    │   ├── terraform.tfstate.backup
    │   ├── terraform.tfvars
    │   ├── terraform.tfvars.example
    │   ├── Ubuntu_VM.md
    │   └── variables.tf
    └── ubuntu_vm_microk8s
        ├── ansible
        │   ├── inventory.ini
        │   ├── microk8s_install.yaml
        │   ├── nginx_install.yaml
        │   └── ping.yaml
        ├── ansible.cfg
        ├── data.tf
        ├── main.tf
        ├── output.tf
        ├── provider.tf
        ├── templates
        │   ├── cloud_init.tftpl
        │   ├── meta_data.tftpl
        │   └── network_config.tftpl
        ├── terraform.tfstate
        ├── terraform.tfstate.backup
        ├── terraform.tfvars
        ├── terraform.tfvars.example
        ├── Ubuntu_VM_MicroK8S.md
        └── variables.tf
```
