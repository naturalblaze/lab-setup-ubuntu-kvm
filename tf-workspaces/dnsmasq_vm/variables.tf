# variable: Variables for dnsmasq_vm workspace

variable "libvirt_pool_path" {
  description = "local path for libvirt storage pool"
  type        = string
  default     = "/var/lib/libvirt/images/terraform/dnsmasq_vm"
}

variable "img_url" {
  description = "linux url for qcow2 image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "hostname" {
  description = "vm hostname"
  type        = string
  default     = "dnsmasq"

  validation {
    condition     = can(regex("^[0-9A-Za-z_-]+$", var.hostname))
    error_message = "The variable 'hostname' must only contain alphanumeric characters (a-z, A-Z, 0-9, _-) and no spaces or special characters."
  }
}

variable "packages" {
  description = "linux packages to install, qemu-guest-agent needed for terraform"
  type        = list(string)
  default     = ["qemu-guest-agent", "dnsmasq"]
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
  description = "memory allocated to vm"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory > 0
    error_message = "The 'memory' must be a non-negative number (greater than 0)."
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
  description = "vm user"
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
  description = "ssh public key for local user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  sensitive   = true

  validation {
    condition     = fileexists(var.ssh_public_key)
    error_message = "The specified configuration file does not exist at '${var.ssh_public_key}'."
  }
}

variable "network" {
  description = "kvm network"
  type        = string
  default     = "default"
}

variable "ip_address" {
  description = "static IPv4 address for vm"
  type        = string

  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.ip_address))
    error_message = "The provided IP address is not a valid IPv4 address."
  }
}

variable "subnet_cidr" {
  description = "subnet mask (cidr)"
  type        = number

  validation {
    condition     = var.subnet_cidr >= 0 && var.subnet_cidr <= 32
    error_message = "The 'subnet_cidr' must be valid CIDR notation (between 0 and 32)."
  }
}

variable "gateway" {
  description = "default gateway IPv4 address"
  type        = string

  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.gateway))
    error_message = "The provided Gateway IP address is not a valid IPv4 address."
  }
}

variable "nameservers" {
  description = "list of external dns servers"
  type        = list(any)
  default     = ["1.1.1.1", "1.0.0.1"]
}

variable "domain_name" {
  description = "domain name"
  type        = string
  default     = "local.domain"
}

variable "domain_hosts" {
  description = "list of local hosts"
  type        = list(string)
  default     = ["127.0.0.1  dnsmasq"]
}