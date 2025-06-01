# Optional Installs

## Description

This module will document some of the optional components I have installed. These components are not required for the automation to run but can be useful.

## Table of Contents

- [Cockpit](#cockpit-setup)
- [GitHub](#github-setup)
- [VSCode](#vscode-setup)
- [Ansible](#ansible-setup)


### Cockpit Setup

I'm using [Cockpit](https://cockpit-project.org/) for a graphical WebUI which is free and easy to setup. We will be using IaC tools to automate the deployment of our virtual environments, but it is nice to have a graphical interface to view the resources and their configurations or connect to the consoles in case you have any issues or for troubleshooting.

```bash
# Install Cockpit
. /etc/os-release
sudo apt update && sudo apt install -y -t ${VERSION_CODENAME}-backports cockpit cockpit-machines

# Enable cockpit to autostart and start
sudo systemctl enable cockpit.socket
sudo systemctl start cockpit
sudo systemctl status cockpit

# Reboot for fwupd-refresh down
sudo reboot now

# Test URL
https://<server-hostname or ip-address>:9090/system
```


### GitHub Setup

> :exclamation: **Note:** This requires you already have a GitHub account.

I'm using the SSH key pair we created in the [Server_Setup - SSH Key Setup](./Server_Setup.md.md#SSH-Key-Setup) for authentication into GitHub to be able to pull code down from GitHub repositories. This of course optional as you could authenticate with HTTPS as well.


[Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

- Setup SSH key: https://github.com/settings/ssh/new
    - Title: Ubuntu Lab SSH key
    - Key Type: Authentication
    - Key: 

```bash
mkdir ~/tf-workspaces
cd ~/tf-workspaces
git clone git@github.com:naturalblaze/lab-setup-ubuntu-kvm.git
```


### VSCode Setup

I'm using VSCode to connect to the lab server. It is a cross-platform editor with a extensive sweet of extensions. VSCode has a extension for `Remote - SSH` that lets you easily connect to a remote Linux server and edit code files and access the servers terminal. This of course optional as you could remote in with any terminal program that you are more comfortable with.

- Install VSCode on the device you want to connect from: [Download](https://code.visualstudio.com/Download)

- Copy the text from the SSH Private key on the lab server

```bash
cat ~/.ssh/id_ed25519
```

- Create the SSH Private key file from the system you are trying to connect from

> :exclamation: **Note:** My personal laptop is running Linux PopOS so the path to the SSH Private key is the same as on the lab server.  If you are connecting from a Windows devices your path would be something like `C:\Users\<username>\.ssh`

```bash
# Create file SSH Private key
cat > ~/.ssh/id_ed25519 << EOF
<Text from lab server id_ed25519 file>
EOF
```

- Open VSCode and download the `Remote - SSH` extension

  - Extensions button on left bar

  - Search for `Remote - SSH` and Install

- Configure SSH Hosts in VSCode

  - Select `><`  button in bottom left corner

  - Connect to Host

  - Configure SSH Hosts

  - Select the path to SSH config file for your system

  - Add the below code to your config file

  ```bash
  Host <lab server name>
    HostName <lab server name or ip address>
    User <lab username>
    IdentityFile <path to id_ed25519>
  ```


### Ansible Setup

Ansible is a very powerful open-source agentless automation tool. You could in fact do all these same KVM deployments just using Ansible. I am mainly going to use it for installing software and configurations during our deployments as I find it easier to deploy these things via Ansible than through Terraform. 

[Ansible Docs](https://docs.ansible.com/)

- Update your system

```bash
sudo apt update && sudo apt upgrade -y
```

- Install software properties common

```bash
sudo apt install software-properties-common -y
```

- Add Ansible Official PPA

```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
```

- Install Ansible

```bash
sudo apt update && sudo apt-get -y install ansible
```

- Validate Ansible is installed

```bash
ansible --version
```


### [Next Lesson - Deploy Ubuntu VM with Terraform](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md)

-----

### Resources

#### Repo Table of Contents:

- [Home](./README.md)

- [Server Setup](./Server_Setup.md)

- [Optional Installs](./Optional_Installs.md)

- Terraform Deployments:

    - [Ubuntu VM](./tf-workspaces/ubuntu_vm/Ubuntu_VM.md) - Deploy a simple Ubuntu Server VM to test your lab setup.

    - [Ubuntu VM K8S Single Node with MicroK8S](./tf-workspaces/ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md) - Deploy a simple Ubuntu Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.

-----

#### GitHub Repo Information:

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

-----
