# MicroK8S VM K8S Single Node with Terraform

Our next Terraform workspace will be the deployment of a single Ubuntu Linux VM and then installing and configuring a single node MicroK8S (Kubernetes). Rarely do you only need to deploy a vanilla Linux system so lets expand and add some features to our deployment.

> :bulb: **Note:** I'm separating the Terraform configurations into separate files for the different configuration blocks to help with readability but the file structure and naming patterns are completely up to you. You can have all the configurations in the same `.tf` file if you chose. 

## Table of Contents

* [Description](#description)

* [Environment](#environment)

* [Terraform VM Deployment](#terraform-vm-deployment)

* [Terraform Configuration Walkthrough](#terraform-configurations-walkthrough)

* [Ansible Deployment](#ansible-deployment)

    * [Ansible Testing](#ansible-testing)

    * [Install MicroK8S](nstall-microk8s)

    * [Deploy Nginx Container](#deploy-nginx-container)

* [Delete Terraform Resources](#delete-terraform-resources)

## Description

Deploy a single Ubuntu Server VM with Terraform to our lab system and configure Kubernetes MicroK8S single node enviornment.
Now that we have deployed a simple Ubuntu Server VM that is not much fun, so lets expand on that and make something more usable. We will add some additional steps to the deployment to expand the `QCOW2` disk (since it only provisioned with a very small filesystem) and use `Ansible` to install and configure Kubernetes MicroK8S along with a sample `NGINX` application.

Key Aspects:

* Create a KVM `storage_pool`

* Download an Ubuntu server cloud image `QCOW2` disk

* Expand the `QCOW2` disk to add some additional storage to the system (ex. 20G)

* Deploy an Ubuntu server `virtual machine`

* Configure VM with `cloud-init`

* Ansible Configs:

  > :bulb: **Note:** I'm using Ansible for the install and configuration `microk8s`. You could do this via `cloud-init` and/or `remote-exec` but Terraform is not very good doing configurations on servers (or at least validating the install status) and waiting for apps to be fully available

  * Install Kubernetes and configure single node cluster with `microk8s snap`

  * Enable MicroK8S addons: `dns hostpath-storage dashboard helm3`

  * Deploy a K8S service for microk8s dashboard to make it accessible via the host IP address

  * Deploy a NGINX container with a LoadBalancer service

## Environment

To set or override any of the `variables.tf` values for your specific use just rename `terraform.tfvars.example` to `terraform.tfvars` and set the values you want for your environment.

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| local_root_pwd | ✅/🚫 | None | Only required if your lab server requires a user password for sudo commands. |
| libvirt_pool_path | ✅ | /var/lib/libvirt/images/terraform/microk8s_vm | Local path for the Libvirt storage pool to be created. |
| img_url | ✅ | https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img | Linux URL for QCOW2 image. |
| hostname | ✅ | microk8s | VM hostname. |
| packages | ✅ | qemu-guest-agent | Linux packages to install during the cloud-init configuration, `qemu-guest-agent` needed for Terraform to validate the install. |
| cpus | ✅ | 2 | CPUs allocated to VM. |
| memory | ✅ | 2048 | Memory allocated to VM (in MB). |
| disk_size | ✅ | 0 | Capacity to add to `qcow2` disk (in GB). |
| root_pwd | ✅ | rootplease | VM root password. |
| username | ✅ | ubuntu | VM user to create. |
| user_pwd | ✅ | userplease | VM user password. |
| ssh_public_key | ✅ | ~/.ssh/id_ed25519.pub | Path to SSH Public key for user. |
| ssh_private_key | ✅ | ~/.ssh/id_ed25519 | Path to SSH Private key for user. |
| network | ✅ | default | KVM network to use for VM network interface. (`default` or `hostbridge`) |
| dhcp | ✅ | True | Use DHCP for VM network config. |
| ip_address | 🚫 | None | Static IP address for VM. * |
| subnet_cidr | 🚫 | 24 | CIDR Subnet mask for VM. * |
| gateway | 🚫 | None | Default gateway IP address. * |
| nameservers | 🚫 | ["1.1.1.1", "1.0.0.1"] | List of DNS nameservers. * |
> \* Only needed if DHCP is set to `False`

## Terraform VM Deployment

I have all the needed configuration files setup in the Github repository and there are default values set for all the required variables so if you do not want or need to change any of the defaults you can easily just clone the repo down and deploy the initial environment. I will walk through what all the different files are doing later in the wiki.

> :bulb: **Note:** I would recommend at least adding a few GB of disk space with the `disk_size` variable as the default Ubuntu cloud image has a very small filesystem.

* Clone [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm) code from GitHub

```bash
# HTTPS
git clone https://github.com/naturalblaze/lab-setup-ubuntu-kvm.git

# SSH
git clone git@github.com:naturalblaze/lab-setup-ubuntu-kvm.git
```


* Change to Terraform workspace directory

```bash
cd lab-setup-ubuntu-kvm/tf-workspaces/microk8s_vm/
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

> :warning: If you are using a source control system like GitHub make sure you exlude your `.tfvars`, `ansible/inventory.ini`, and `ansible.cfg` files from commits or your sensitive secrets or environment details could be accessible to the public and introduce vulnerabilities.

* [main.tf](./main.tf) - The main/resource block defines a piece of infrastructure and specifies the settings for Terraform to create it with. The arguments that an individual resource supports are determined by the provider. This is where all the different resources needed for our enviornment are defined. More details at [Terraform Resource Block](https://developer.hashicorp.com/terraform/language/block/resource)

* templates - We are using this with the `templates` folder and the `.tftpl` template files so that we can render configurations with our variables injected for the cloud-init configurations of the VM. More details at [Terraform Template Files](https://developer.hashicorp.com/terraform/language/functions/templatefile)

    * [cloud_init.tftpl](./templates/cloud_init.tftpl) - Cloud-init Linux system configuration: installed packages, commands to run, user and password setup, etc.

    * [meta_data.tftpl](./templates/meta_data.tftpl) - Cloud-init meta-data for Linux system.

    * [network_config.tftpl](./templates/network_config.tftpl) - Cloud-init network configuration for Linux system. Allows for DHCP or static network configurations.

* [output.tf](./output.tf) - The output block lets you expose information about your infrastructure. We use this to show the rendered template information and display the resource IP address after deployment. More details at [Terraform Output Block](https://developer.hashicorp.com/terraform/language/block/output)

## Ansible Deployment

[Ansible Install](../../Optional_Installs.md#ansible-install)

### Ansible Testing

Part of the Terraform VM deployment created an `ansible.cfg` file with some needed configurations to connect to the VM and an inventory file `ansible/inventory.ini` for the playbooks to use.

* Test connecting to the VM with the `ping` module

```bash
ansible-playbook -i ansible/inventory.ini ansible/ping.yaml
```

### Install MicroK8S

* Install and configure `microk8s`

```bash
ansible-playbook -i ansible/inventory.ini ansible/microk8s_install.yaml
```

> :bulb: **Note:** One of the addons we enabled was `dashboard` which allows for a WebUI to view the status of our K8S cluster. The URL and Token to connect to the WebUI are printed in the debug task at the end of the playbook

* Validate microk8s install

```bash
ssh <username>@<ip-address>
microk8s version
microk8s status --wait-ready
kubectl version
kubectl get nodes
```

### Deploy Nginx Container

Now we have a fully functional `microk8s` install let's deploy a simple NGINX application with an `LoadBalancer` service to expose the app to the `8080` port of the lab server

* Deploy `nginx` container with `LoadBalancer` service

```bash
ansible-playbook -i ansible/inventory.ini ansible/nginx_install.yaml
```

* Validate NGINX install: `https://<server-ip>:8080`

> :exclamation: **Note:** The `nginx_install.yaml` playbook creates a new namespace in our K8S instance named `nginx-test`

```bash
ssh <username>@<ip-address>
kubectl get pods --namespace=nginx-test
kubectl get services --namespace=nginx-test
```


## Delete Terraform Resources

* Destroy Terraform resources

> :bulb: **Note:** Use argument `--auto-approve` to bypass prompt for approval

```bash
terraform destroy
```

## **🎉 Congratulations you have deployed a VM using Terraform, installed and configured Ansible on your lab server, deployed and configured MicroK8S on your VM, and deployed a NGINX container and service using Ansible 🎉**

### [Next Project - Deploy DNS Ubuntu VM with Dnsmasq](../dnsmasq_vm/DNSMasq_VM.md)

---

### Resources

#### Repo Table of Contents:

* [Home](../../README.md)

* [Server Setup](../../Server_Setup.md)

* [Optional Installs](../../Optional_Installs.md)

* Terraform Deployments:

    * [Ubuntu VM with Terraform](../ubuntu_vm/Ubuntu_VM.md) - Deploy an Ubuntu Linux Server VM.

    * [MicroK8S Single Node Ubuntu VM with Terraform](./MicroK8S_VM.md) - Deploy an Ubuntu Linux Server VM, install and configure MicroK8S, and deploy your first K8S app with Ansible.

    * [Dnsmasq VM with Terraform](../dnsmasq_vm/DNSMasq_VM.md) - Deploy an Ubuntu Linux Server VM and configure Dnsmasq.

#### Directory Structure:

```text
microk8s_vm/
├── ansible
│   ├── microk8s_install.yaml
│   ├── nginx_install.yaml
│   └── ping.yaml
├── main.tf
├── MicroK8S_VM.md
├── output.tf
├── provider.tf
├── templates
│   ├── cloud_init.tftpl
│   ├── meta_data.tftpl
│   └── network_config.tftpl
├── terraform.tfvars.example
└── variables.tf
```

---

#### GitHub Repo Information:

GitHub Repository: [lab-setup-ubuntu-kvm](https://github.com/naturalblaze/lab-setup-ubuntu-kvm)

Author: Blaze Bryant [naturalblaze](https://github.com/naturalblaze)

---
