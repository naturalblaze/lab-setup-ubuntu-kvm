# Ubuntu VM with Terraform


## Table of Contents

- [Description](./Ubuntu_VM.md#description)

- [Terraform VM Deployment](./Ubuntu_VM.md#terraform-vm-deployment)


## Description

Deploy a simple Ubuntu Server VM with Terraform to test your lab setup.

Key Aspects:

- Create a KVM `storage_pool`

- Download an Ubuntu server cloud image `QCOW2` disk

- Deploy an Ubuntu server `virtual machine`

- Configure VM with `cloud-init`


## Terraform VM Deployment

- Clone [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm) code from GitHub

    > :warning: **Note:** This is if you setup SSH key access using [Optional Installs - GitHub Setup](../../Optional_Installs.md#github-setup), otherwise use HTTPS URL and follow the username and password prompts

    ```bash
    git clone git@github.com:naturalblaze/lab-setup-ubuntu-kvm.git
    ```

- Change to Terraform workspace directory

    ```bash
    cd lab-setup-ubuntu-kvm/tf-workspaces/ubuntu_vm
    ```

> :exclamation: **Note:** There are default values set for all the required variables so if you do not want or need to change any of the defaults you can skip editing `terraform.tfvars.example` and renaming it to `terraform.tfvars`, just skip to the `Initialize Terraform workspace` step

- Edit the variables `terraform.tfvars.example` file with the values you want for your environment

    | Name | Required | Default | Description |
    | ---- | -------- | ------- | ----------- |
    | libvirt_pool_path | ✅ | /var/lib/libvirt/images/terraform | Local path for the Libvirt storage pool to be created. |
    | ubuntu_img_url | ✅ | https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img | Linux URL for QCOW2 image. |
    | hostname | ✅ | ubuntu | VM hostname. |
    | packages | ✅ | qemu-guest-agent | Linux packages to install during the cloud-init configuration, `qemu-guest-agent` needed for Terraform to validate the install. |
    | cpus | ✅ | 1 | CPUs allocated to VM. |
    | memory | ✅ | 1024 | Memory allocated to VM. |
    | root_pwd | ✅ | superrootpassword | VM root password. |
    | username | ✅ | ubuntu | VM user to create. |
    | ssh_public_key | ✅ | ~/.ssh/id_ed25519.pub | Path to SSH Public key for user. |
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

- Destroy Terraform resources

    > :exclamation: **Note:** Use argument `--auto-approve` to bypass prompt for approval

    ```bash
    terraform destroy
    ```


## **🎉 Congratulations you have completed your first IaC deployment using Terraform 🎉**


### [Next Lesson - Deploy Ubuntu VM with MicroK8S](../ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md)

-----

### Resources

#### Repo Table of Contents:

- [Home](../../README.md)

- [Server Setup](../../Server_Setup.md)

- [Optional Installs](../../Optional_Installs.md)

- Terraform Deployments:

    - [Ubuntu VM](./Ubuntu_VM.md) - Deploy a simple Ubuntu Server VM to test your lab setup.

    - [Ubuntu VM K8S Single Node with MicroK8S](../ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md) - Deploy a simple Ubuntu Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.


#### Directory Structure:

```text
ubuntu_vm/
├── data.tf
├── output.tf
├── provider.tf
├── resource.tf
├── templates
│   ├── cloud_init.tftpl
│   ├── meta_data.tftpl
│   └── network_config.tftpl
├── terraform.tfvars.example
├── Ubuntu_VM.md
└── variables.tf
```

-----

#### GitHub Repo Information:

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

-----
