terraform {
  required_version = ">= 0.12"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6.14"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://root@185.3.124.180/system?keyfile=/Users/mahdiar/.ssh/id_rsa&socket=/var/run/libvirt/libvirt-sock"
}