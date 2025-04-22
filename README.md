# Automate your ssh-IT

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)


## Description

I wanted to create a lab environment where I could easily deploy and destroy virtualized technologies using IaC tools for learning, testing, and development purposes. I had an old Intel NUC I used for the base server running Ubuntu 24.04 Server with KVM, QEMU, and Libvirt to support virtualization.

> :exclamation: **Note:** I'm using Ubuntu 24.04 server image to run as a headless server that I can SSH to via the command-line, but you could also use the Desktop version if your more comfortable with a Graphical interface.


## Repo Table of Contents:

- [Home](./README.md)

- [Server Setup](./Server_Setup.md)

- [Optional Installs](./Optional_Installs.md)

- Terraform Deployments:

    - [Ubuntu VM](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md) - Deploy a simple Ubuntu Server VM to test your lab setup.
