# Ubuntu VM K8S Single Node with MicroK8S


## Table of Contents

- [Description](./Ubuntu_VM_MicroK8S.md#description)

    - [Key Aspects](./Ubuntu_VM_MicroK8S.md#key-aspects)

- [Terraform VM Deployment](./Ubuntu_VM_MicroK8S.md#terraform-vm-deployment)

- [Ansible Install and Deployment](./Ubuntu_VM_MicroK8S.md#ansible-install-and-deployment)

    - [Ansible Setup](./Ubuntu_VM_MicroK8S.md#ansible-setup)

    - [Ansible Testing](./Ubuntu_VM_MicroK8S.md#ansible-testing)

    - [Install MicroK8S](./Ubuntu_VM_MicroK8S.md#install-microk8s)

    - [Deploy Nginx Container](./Ubuntu_VM_MicroK8S.md#deploy-nginx-container)

- [Delete Terraform Resources](./Ubuntu_VM_MicroK8S.md#delete-terraform-resources)


## Description

Now that we have deployed a simple Ubuntu Server VM that is not much fun, so lets expand on that and make something more usable. We will add some additional steps to the deployment to expand the `QCOW2` disk (since it only provisioned with a very small filesystem) and use `Ansible` to install and configure Kubernetes MicroK8S along with a sample `NGINX` application.


### Key Aspects

- Create a KVM `storage_pool`

- Download an Ubuntu server cloud image `QCOW2` disk

- Expand the `QCOW2` disk to add some additional storage to the system (ex. 20G)

- Deploy an Ubuntu server `virtual machine`

- Configure VM with `cloud-init`

- Using Ansible:

  > :exclamation: **Note:** I'm using Ansible for the install and configuration `microk8s`. You could do this via `cloud-init` and/or `remote-exec` but Terraform is not very good doing configurations on servers and waiting for apps to be fully available

  - Install Kubernetes and configure single node cluster with `microk8s snap`

  - Enable MicroK8S addons: `dns hostpath-storage dashboard helm3`

  - Deploy a K8S service for microk8s dashboard to make it accessible via the host IP address

  - Deploy a NGINX container with a LoadBalancer service


## Terraform VM Deployment

- Clone [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm) code from GitHub

    > :warning: **Note:** This is if you setup SSH key access using [Optional Installs - GitHub Setup](../../Optional_Installs.md#github-setup), otherwise use HTTPS URL and follow the username and password prompts

    ```bash
    git clone git@github.com:naturalblaze/lab-setup-ubuntu-kvm.git
    ```

- Change to Terraform workspace directory

    ```bash
    cd lab-setup-ubuntu-kvm/tf-workspaces/ubuntu_vm_microk8s
    ```

> :exclamation: **Note:** There are default values set for all the required variables so if you do not want/need to change any of the defaults you can skip editing `terraform.tfvars.example` and renaming it to `terraform.tfvars`.

> :warning: You only need to change and uncomment `local_root_pwd` if you lab server requires a password for sudo privileges, uncomment the `local_root_pwd` in `variables.tf`, and adjust the command in `resource.tf`

- Edit the variables `terraform.tfvars.example` file with the values you want for your environment

    | Name | Required | Default | Description |
    | ---- | -------- | ------- | ----------- |
    | local_root_pwd | ✅ or 🚫 | None | This is only required if your lab server requires a user password for sudo commands. |
    | libvirt_pool_path | ✅ | /var/lib/libvirt/images/terraform | Local path for the Libvirt storage pool to be created. |
    | ubuntu_img_url | ✅ | https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img | Linux URL for QCOW2 image. |
    | hostname | ✅ | ubuntu | VM hostname. |
    | packages | ✅ | qemu-guest-agent | Linux packages to install during the cloud-init configuration, `qemu-guest-agent` needed for Terraform to validate the install. |
    | cpus | ✅ | 2 | CPUs allocated to VM. |
    | memory | ✅ | 2048 | Memory allocated to VM (in MB). |
    | disk_size | ✅ | 20 | Capacity to add to `qcow2` disk (in GB). |
    | root_pwd | ✅ | superrootpassword | VM root password. |
    | username | ✅ | ubuntu | VM user to create. |
    | ssh_public_key | ✅ | ~/.ssh/id_ed25519.pub | Path to SSH Public key to use for user on lab server. |
    | dhcp | ✅ | True | Use DHCP for VM network config. |
    | network | ✅ | default | KVM network to use for VM network interface. |
    | ip_address | 🚫 | None | Static IP address for VM. Only needed if DHCP is set to False. |
    | subnet | 🚫 | None | CIDR Subnet mask for VM. Only needed if DHCP is set to False. |
    | gateway | 🚫 | None | Default gateway IP address. Only needed if DHCP is set to False. |
    | nameservers | 🚫 | None | List of DNS nameservers. Only needed if DHCP is set to False. |

- Rename `terraform.tfvars.example` file to `terraform.tfvars`

    ```bash
    mv terraform.tfvars.example terraform.tfvars
    ```

- Initialize Terraform workspace

    ```bash
    terraform init
    ```

- Format Terraform files

    ```bash
    terraform fmt
    ```

- Validate Terraform configuration

    ```bash
    terraform validate
    ```

- Plan Terraform deployment

    ```bash
    terraform plan
    ```

- Deploy Terraform resources

    > :exclamation: **Note:** Use argument `--auto-approve` to bypass prompt for approval

    ```bash
    terraform apply
    ```

- Validate your deployment

    > :exclamation: **Note:** You should see the IP Address that was assigned to your VM in the output of the `terraform apply` command

    ```bash
    ssh <username>@<ip-address>
    ```


## Ansible Install and Deployment

### Ansible Setup

Follow the installation instructions in [Optional Installs - Ansible Install](../../Optional_Installs.md#ansible-install) to install ansible on the lab server if you haven't already done so.

### Ansible Testing

Part of the Terraform VM deployment created an `ansible.cfg` file with some needed configurations to connect to the VM and an inventory file `ansible/inventory.ini` for the playbooks to use.

- Test connecting to the VM with the `ping` module

    ```bash
    ansible-playbook -i ansible/inventory.ini ansible/ping.yaml
    ```

### Install MicroK8S

- Install and configure `microk8s`

    ```bash
    ansible-playbook -i ansible/inventory.ini ansible/microk8s_install.yaml
    ```

    > :exclamation: **Note:** One of the addons we enabled was `dashboard` which allows for a WebUI to view the status of our K8S cluster. The URL and Token to connect to the WebUI are printed in the debug task at the end of the playbook

- Validate microk8s install

    ```bash
    ssh <username>@<ip-address>
    microk8s version
    microk8s status --wait-ready
    kubectl version
    kubectl get nodes
    ```

### Deploy Nginx Container

Now we have a fully functional `microk8s` install let's deploy a simple NGINX application with an `LoadBalancer` service to expose the app to the `8080` port of the lab server

- Deploy `nginx` container with `LoadBalancer` service

    ```bash
    ansible-playbook -i ansible/inventory.ini ansible/nginx_install.yaml
    ```

- Validate NGINX install: `https://<server-ip>:8080`

    > :exclamation: **Note:** The `nginx_install.yaml` playbook creates a new namespace in our K8S instance named `nginx-test`

    ```bash
    ssh <username>@<ip-address>
    kubectl get pods --namespace=nginx-test
    kubectl get services --namespace=nginx-test
    ```


## Delete Terraform Resources

- Destroy Terraform resources

    > :exclamation: **Note:** Use argument `--auto-approve` to bypass prompt for approval

    ```bash
    terraform destroy
    ```

## **🎉 Congratulations you have deployed a VM using Terraform, installed and configured Ansible on your lab server, deployed and configured MicroK8S on your VM, and installed a NGINX container and service using Ansible 🎉**


### [Next Lesson - Coming Soon]()

-----

### Resources

#### Repo Table of Contents:

- [Home](../../README.md)

- [Server Setup](../../Server_Setup.md)

- [Optional Installs](../../Optional_Installs.md)

- Terraform Deployments:

    - [Ubuntu VM](../ubuntu_vm/Ubuntu_VM.md) - Deploy a simple Ubuntu Server VM to test your lab setup.

    - [Ubuntu VM K8S Single Node with MicroK8S](./Ubuntu_VM_MicroK8S.md) - Deploy a simple Ubuntu Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.


#### Directory Structure:

```text
ubuntu_vm_microk8s/
├── ansible
│   ├── microk8s_install.yaml
│   ├── nginx_install.yaml
│   └── ping.yaml
├── data.tf
├── output.tf
├── provider.tf
├── resource.tf
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

-----

#### GitHub Repo Information:

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

-----
