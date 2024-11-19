output "vm_ip_addresses" {
  description = "IP addresses assigned to the VM"
  value       = libvirt_domain.vm.network_interface.0.addresses
}

output "vm_domain" {
  description = "Libvirt domain of the VM"
  value       = libvirt_domain.vm.id
}