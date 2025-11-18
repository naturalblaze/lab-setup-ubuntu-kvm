# variable: Variables for ubuntu_vm module

variable "local_root_pwd" {
  description = "local host root password if sudo requires password"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.local_root_pwd == "" || can(regex("^[\\S]+$", var.local_root_pwd))
    error_message = "The variable 'local_root_pwd' must not contain any spaces."
  }
}

variable "libvirt_pool_path" {
  description = "local path for libvirt storage pool"
  type        = string
  default     = "/var/lib/libvirt/images/terraform/ubuntu_microk8s"
}

variable "img_url" {
  description = "linux url for qcow2 image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "hostname" {
  description = "vm hostname"
  type        = string
  default     = "microk8s"

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]+$", var.hostname))
    error_message = "The variable 'hostname' must only contain alphanumeric characters (a-z, A-Z, 0-9, _-) and no spaces or special characters."
  }
}

variable "packages" {
  description = "linux packages to install, qemu-guest-agent needed for terraform"
  type        = list(any)
  default     = ["qemu-guest-agent"]
}

variable "cpus" {
  description = "cpus allocated to vm"
  type        = number
  default     = 2

  validation {
    condition     = var.cpus > 0
    error_message = "The 'cpus' must be a non-negative number (greater than 0)."
  }
}

variable "memory" {
  description = "memory allocated to vm (in MB)"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory > 0
    error_message = "The 'memory' must be a non-negative number (greater than 0)."
  }
}

variable "disk_size" {
  description = "disk size increase for vm (in GB)"
  type        = number
  default     = 20

  validation {
    condition     = var.disk_size > 0
    error_message = "The 'disk_size' must be a non-negative number (greater than 0)."
  }
}

variable "root_pwd" {
  description = "vm root password"
  type        = string
  default     = "rootplease"
  sensitive   = true

  validation {
    condition     = can(regex("^[\\S]+$", var.root_pwd))
    error_message = "The variable 'root_pwd' must not contain any spaces."
  }
}

variable "username" {
  description = "vm user to create"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]+$", var.username))
    error_message = "The variable 'username' must only contain alphanumeric characters (a-z, A-Z, 0-9, _-) and no spaces or special characters."
  }
}

variable "user_pwd" {
  description = "vm user password"
  type        = string
  default     = "userplease"
  sensitive   = true

  validation {
    condition     = can(regex("^[\\S]+$", var.user_pwd))
    error_message = "The variable 'user_pwd' must not contain any spaces."
  }
}

variable "ssh_public_key" {
  description = "ssh public key for local lab server user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  sensitive   = true

  validation {
    condition     = fileexists(var.ssh_public_key)
    error_message = "The specified configuration file does not exist at '${var.ssh_public_key}'."
  }
}

variable "ssh_private_key" {
  description = "ssh private key for local lab server user"
  type        = string
  default     = "~/.ssh/id_ed25519"
  sensitive   = true

  validation {
    condition     = fileexists(var.ssh_private_key)
    error_message = "The specified configuration file does not exist at '${var.ssh_private_key}'."
  }
}

variable "network" {
  description = "kvm network"
  type        = string
  default     = "default"
}

variable "dhcp" {
  description = "use dhcp for network"
  type        = bool
  default     = true
}

variable "ip_address" {
  description = "static ip address for vm"
  type        = string
  default     = ""

  validation {
    condition     = var.ip_address == "" || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.ip_address))
    error_message = "The provided IP address is not a valid IPv4 address."
  }
}

variable "subnet_cidr" {
  description = "subnet mask (cidr)"
  type        = number
  default     = 24

  validation {
    condition     = var.subnet_cidr >= 0 && var.subnet_cidr <= 32
    error_message = "The 'subnet_cidr' must be valid CIDR notation (between 0 and 32)."
  }
}

variable "gateway" {
  description = "default gateway ip address"
  type        = string
  default     = ""

  validation {
    condition     = var.gateway == "" || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.gateway))
    error_message = "The provided Gateway IP address is not a valid IPv4 address."
  }
}

variable "nameservers" {
  description = "list of dns servers ip addresses"
  type        = list(any)
  default     = ["1.1.1.1", "1.0.0.1"]
}
