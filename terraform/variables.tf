variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "vm_pool" {
  type    = string
  default = "pool1"
}

variable "vm_pool_path" {
  type    = string
  default = "/home/ubuntu/kvm-remote-host/kvm/pool1"
}

variable "base_image_name" {
  type    = string
  default = "ubuntu-22.04-server-cloudimg-amd64-disk-kvm.img"
}

variable "base_image_source" {
  type    = string
  default = "/home/ubuntu/kvm-remote-host/kvm/images/ubuntu-22.04-server-cloudimg-amd64-disk-kvm.img"
}

variable "vm_num" {
  type    = number 
  description = "Number of VMs to create (including master)"
}

# RAM
variable "vm_memory" {
  type    = number
  default = 1024
}

# Storage
variable "vm_disk_size" {
  type        = number
  default     = 20 
  description = "Size of the VM disk in GB"
}

variable "vm_vcpu" {
  type    = number
  default = 1
}

variable "base_ip" {
  type    = string
  default = "192.168.122.100"
}

variable "vm_ips" {
  type    = list(string)
  default = ["192.168.122.100","192.168.122.101","192.168.122.102","192.168.122.103","192.168.122.104","192.168.122.105"]
}

locals {
  vm_ips = var.vm_ips != [] ? var.vm_ips : [
    for i in range(var.vm_num) : 
    cidrhost("${var.base_ip}/24", i)
  ]
}

variable "vm_hostname_prefix" {
  type    = string
  default = "slave"
}

variable "vm_hostname" {
  type    = list(string)
  default = []
}

locals {
  vm_hostname = [
    for i in range(var.vm_num) : 
      i == 0 ? "master" : "${var.vm_hostname_prefix}${i}"
  ]
}


variable "gateway" {
  type    = string
  default = "192.168.122.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}
