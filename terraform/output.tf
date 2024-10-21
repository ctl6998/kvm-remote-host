output "vm_details" {
  value = [
    for vm in libvirt_domain.vm : {
      name     = vm.name
      ip       = length(vm.network_interface) > 0 ? (
        length(vm.network_interface[0].addresses) > 0 ? vm.network_interface[0].addresses[0] : "Waiting for IP"
      ) : "No network interface"
      hostname = vm.name
    }
  ]
}

output "ips" {
  value = [
    for vm in libvirt_domain.vm : 
      length(vm.network_interface) > 0 ? (
        length(vm.network_interface[0].addresses) > 0 ? vm.network_interface[0].addresses[0] : "Waiting for IP"
      ) : "No network interface"
  ]
}
