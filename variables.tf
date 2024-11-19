variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "username" {
  description = "Username for the VM"
  type        = string
}

variable "password" {
  description = "Password for the VM user"
  type        = string
}

variable "cloud_image_url" {
  description = "URL of the cloud image to use"
  type        = string
  default     = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

variable "cloud_image_name" {
  description = "Name for the downloaded cloud image"
  type        = string
  default     = "ubuntu-cloudimg-focal.qcow2"
}

variable "bridge1_name" {
  description = "Name of the first bridge to connect to (e.g., br0)"
  type        = string
}

variable "bridge2_name" {
  description = "Name of the second bridge to connect to (e.g., br1)"
  type        = string
}

variable "vm_interface1_config" {
  description = "Network configuration for the first interface (connected to bridge1)"
  type = object({
    dhcp4       = bool
    addresses   = list(string)
    gateway4    = string
    nameservers = object({
      addresses = list(string)
    })
  })
}

variable "vm_interface2_config" {
  description = "Network configuration for the second interface (connected to bridge2)"
  type = object({
    dhcp4       = bool
    addresses   = list(string)
    gateway4    = string
    nameservers = object({
      addresses = list(string)
    })
  })
}
