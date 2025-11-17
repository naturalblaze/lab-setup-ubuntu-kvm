# Ubuntu VM with Terraform

Our first Terraform workspace will be the deployment of a single Ubuntu Linux VM. This will not only test our lab setup to ensure everything is working correctly, we can also use this to easily deploy a Linux VM if we want to test something. 

> :bulb: **Note:** I'm separating the Terraform configurations into separate files for the different configuration blocks to help with readability but the file structure and naming patterns are completely up to you. You can have all the configurations in the same `.tf` file if you chose. 

## Table of Contents

* [Description](#description)

* [Environment](#environment)

* [Terraform VM Deployment](#terraform-vm-deployment)

* [Terraform Configuration Walkthrough](#terraform-configurations-walkthrough)

## Description

Deploy a single Ubuntu Server VM with Terraform to our lab system.

Key Aspects:

* Create a KVM `storage_pool`

* Download an Ubuntu server cloud image `QCOW2` disk

* Deploy an Ubuntu server `virtual machine`

* Configure VM with `cloud-init`

## Environment

To set or override any of the `variables.tf` values for your specific use just rename `terraform.tfvars.example` to `terraform.tfvars` and set the values you want for your environment.

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| libvirt_pool_path | ✅ | /var/lib/libvirt/images/terraform/ubuntu_vm | Local path for the Libvirt storage pool to be created. |
| img_url | ✅ | https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img | Linux URL for QCOW2 image. |
| hostname | ✅ | ubuntu | VM hostname. |
| packages | ✅ | qemu-guest-agent | Linux packages to install during the cloud-init configuration, `qemu-guest-agent` needed for Terraform to validate the install. |
| cpus | ✅ | 1 | CPUs allocated to VM. |
| memory | ✅ | 1024 | Memory allocated to VM. |
| root_pwd | ✅ | rootplease | VM root password. |
| username | ✅ | ubuntu | VM user to create. |
| ssh_public_key | ✅ | ~/.ssh/id_ed25519.pub | Path to SSH Public key for user. |
| network | ✅ | default | KVM network to use for VM network interface. (`default` or `hostbridge`) |
| dhcp | ✅ | True | Use DHCP for VM network config. |
| ip_address | 🚫 | None | Static IP address for VM. * |
| subnet_cidr | 🚫 | None | CIDR Subnet mask for VM. * |
| gateway | 🚫 | None | Default gateway IP address. * |
| nameservers | 🚫 | None | List of DNS nameservers. * |
> \* Only needed if DHCP is set to `False`

## Terraform VM Deployment

I have all the needed configuration files setup in the Github repository and there are default values set for all the required variables so if you do not want or need to change any of the defaults you can easily just clone the repo down and deploy the initial environment. I will walk through what all the different files are doing later in the wiki.

* Clone [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm) code from GitHub

```bash
# HTTPS
git clone https://github.com/naturalblaze/lab-setup-ubuntu-kvm.git

# SSH
git clone git@github.com:naturalblaze/lab-setup-ubuntu-kvm.git
```

* Change to Terraform workspace directory

```bash
cd lab-setup-ubuntu-kvm/tf-workspaces/ubuntu_vm
```

* Initialize Terraform workspace

```bash
terraform init
```

* Format Terraform files

```bash
terraform fmt
```

* Validate Terraform configuration

```bash
terraform validate
```

* Plan Terraform deployment

```bash
terraform plan
```

> :bulb: **Note:** You can use the argument `--auto-approve` to bypass prompt for approval for apply and destroy

* Deploy Terraform resources

```bash
terraform apply
```

* Validate your deployment

```bash
ssh <username>@<ip-address>
```

* Destroy (delete) Terraform resources

```bash
terraform destroy
```

## Terraform Configurations Walkthrough

* [provider.tf](./provider.tf) - The `terraform/required_providers` and `provider` blocks is how you define and download the plugins used to interact with the cloud providers, SaaS providers, and other APIs. We are deploying to our local KVM resources using the [libvrit](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) provider. After performing the `terraform init` in a workspace the provider plugins are downloaded and added to the workspace. More details at [Terraform Provider Block](https://developer.hashicorp.com/terraform/language/providers).

* [variables.tf](./variables.tf) - Use the variable block to parameterize your configuration, making your modules dynamic, reusable, and flexible by letting them customize behavior with different values at run time. We have defaults set for all the required variables, but they can be overridden by defining them in the `terraform.tfvars` file. More details at [Terraform Variables Block](https://developer.hashicorp.com/terraform/language/block/variable).

* [terraform.tfvars](./terraform.tfvars.example) - A Terraform .tfvars file is a plain text file used to assign values to input variables declared within your Terraform configuration. These files are crucial for separating configuration details from your core infrastructure code, enabling greater flexibility and reusability, especially across different environments (e.g., development, staging, production). An example file is located at [terraform.tfvars.example](./terraform.tfvars.example) just change the filename for it to be consumed by the workspace. More details at [Terraform .tfvars file](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/guides/terraform-vars)

> :warning: If you are using a source control system like GitHub make sure you exlude your `.tfvars` files from commits or your sensitive secrets or environment details could be accessible to the public and introduce vulnerabilities.

* [main.tf](./main.tf) - The main/resource block defines a piece of infrastructure and specifies the settings for Terraform to create it with. The arguments that an individual resource supports are determined by the provider. This is where all the different resources needed for our enviornment are defined. More details at [Terraform Resource Block](https://developer.hashicorp.com/terraform/language/block/resource)

* [data.tf](./data.tf) - The data block fetches data about a resource from the provider without provisioning an associated infrastructure object. You can reference data source attributes to configure other resources, keeping your configuration dynamic and preventing hardcoding. More details at [Terraform Data Block](https://developer.hashicorp.com/terraform/language/block/data)

* templates - We are using this with the `templates` folder and the `.tftpl` template files so that we can render configurations with our variables injected for the cloud-init configurations of the VM. More details at [Terraform Template Files](https://developer.hashicorp.com/terraform/language/functions/templatefile)

    * [cloud_init.tftpl](./templates/cloud_init.tftpl) - Cloud-init Linux system configuration: installed packages, commands to run, user and password setup, etc.

    * [meta_data.tftpl](./templates/meta_data.tftpl) - Cloud-init meta-data for Linux system.

    * [network_config.tftpl](./templates/network_config.tftpl) - Cloud-init network configuration for Linux system. Allows for DHCP or static network configurations.

* [output.tf](./output.tf) - The output block lets you expose information about your infrastructure. We use this to show the rendered template information and display the resource IP address after deployment. More details at [Terraform Output Block](https://developer.hashicorp.com/terraform/language/block/output)

---

## **🎉 Congratulations you have completed your first IaC deployment using Terraform 🎉**

### [Next Project - Deploy Ubuntu VM with MicroK8S](../ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md)

---

### Resources

#### Repo Table of Contents:

* [Home](../../README.md)

* [Server Setup](../../Server_Setup.md)

* [Optional Installs](../../Optional_Installs.md)

* Terraform Deployments:

    * [Ubuntu VM with Terraform](./Ubuntu_VM.md) - Deploy an Ubuntu Linux Server VM.

    * [Ubuntu VM K8S Single Node MicroK8S with Terraform](../ubuntu_vm_microk8s/Ubuntu_VM_MicroK8S.md) - Deploy an Ubuntu Linux Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.


#### Directory Structure:

```text
ubuntu_vm/
├── data.tf
├── main.tf
├── output.tf
├── provider.tf
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
