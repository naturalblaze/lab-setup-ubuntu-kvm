# Lab Setup

## Ubuntu Lab Server with KVM, Libvirt, QEMU, Terraform, and Ansible

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

## Description

I wanted to create a lab environment where I could easily deploy and destroy virtualized technologies using IaC tools for learning, testing, and development purposes. I used a MiniPC I used for a headless Linux base server running Ubuntu 24.04 Server with KVM, QEMU, and Libvirt to support virtualization. You could use different OS', different Linux distributions,  or even desktop for your virtualization server, but we are going to focus on Linux.

### [Next Project - Server Setup](./Server_Setup.md)

---

## Resources

### Repo Table of Contents:

* [Home](./README.md)

* [Server Setup](./Server_Setup.md)

* [Optional Installs](./Optional_Installs.md)

* Terraform Deployments:

    * [Ubuntu VM with Terraform](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md) - Deploy an Ubuntu Linux Server VM.

    * [MicroK8S Single Node Ubuntu VM with Terraform](./tf-workspaces/microk8s_vm/MicroK8S_VM.md) - Deploy an Ubuntu Linux Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.

    * [Dnsmasq VM with Terraform](./tf-workspaces/dnsmasq_vm/DNSMasq_VM.md) - Deploy an Ubuntu Linux Server VM and configure Dnsmasq.

---

### Repo Structure:

```text
lab-setup-ubuntu-kvm/
├── LICENSE
├── Optional_Installs.md
├── README.md
├── Server_Setup.md
└── tf-workspaces
    ├── dnsmasq_vm
    │   ├── DNSMasq_VM.md
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
    │   └── variables.tf
    ├── microk8s_vm
    │   ├── ansible
    │   │   ├── inventory.ini
    │   │   ├── microk8s_install.yaml
    │   │   ├── nginx_install.yaml
    │   │   └── ping.yaml
    │   ├── ansible.cfg
    │   ├── main.tf
    │   ├── MicroK8S_VM.md
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
    │   └── variables.tf
    └── ubuntu_vm
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
        ├── Ubuntu_VM.md
        └── variables.tf
```
