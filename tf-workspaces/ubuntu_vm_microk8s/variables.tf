# variable: Variables for ubuntu_vm module
# Uncomment if you lab server user requires a password for sudo commands
# variable "local_root_pwd" {
#   description = "local host root password if sudo requires password"
#   type        = string
#   default     = ""
#   sensitive   = true
# }

variable "libvirt_pool_path" {
  description = "local path for libvirt storage pool"
  type        = string
  default     = "/var/lib/libvirt/images/terraform"
}

variable "ubuntu_img_url" {
  description = "linux url for qcow2 image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "hostname" {
  description = "vm hostname"
  type        = string
  default     = "ubuntu"
}

variable "packages" {
  description = "linux packages to install, qemu-guest-agent needed for terraform"
  type        = list(any)
  default     = ["qemu-guest-agent"]
}

variable "cpus" {
  description = "cpus allocated to vm"
  type        = string
  default     = "2"
}

variable "memory" {
  description = "memory allocated to vm (in MB)"
  type        = string
  default     = "2048"
}

variable "disk_size" {
  description = "disk size increase for vm (in GB)"
  type        = string
  default     = "20"
}

variable "root_pwd" {
  description = "vm root password"
  type        = string
  default     = "superrootpassword"
  sensitive   = true
}

variable "username" {
  description = "vm user to create"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "ssh public key for local lab server user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  sensitive   = true
}

variable "ssh_private_key" {
  description = "ssh private key for local lab server user"
  type        = string
  default     = "~/.ssh/id_ed25519"
  sensitive   = true
}

variable "dhcp" {
  description = "use dhcp for network"
  type        = string
  default     = "true"
}

variable "network" {
  description = "kvm network"
  type        = string
  default     = "default"
}

variable "ip_address" {
  description = "static ip address for vm"
  type        = string
  default     = ""
}

variable "subnet" {
  description = "subnet mask (cidr)"
  type        = string
  default     = ""
}

variable "gateway" {
  description = "default gateway ip address"
  type        = string
  default     = ""
}

variable "nameservers" {
  description = "list of dns servers ip addresses"
  type        = list(any)
  default     = []
}
