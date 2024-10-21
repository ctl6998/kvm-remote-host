provider "libvirt" {
  uri = var.libvirt_uri
}

resource "libvirt_pool" "vm_pool" {
  name = var.vm_pool
  type = "dir"
  path = var.vm_pool_path
}

resource "libvirt_volume" "ubuntu_base_image" {
  name   = var.base_image_name
  pool   = libvirt_pool.vm_pool.name
  source = var.base_image_source
  format = "qcow2"
}

resource "libvirt_volume" "vm_disk" {
  count          = var.vm_num
  name           = "vm-disk-${count.index}.qcow2"
  pool           = libvirt_pool.vm_pool.name
  base_volume_id = libvirt_volume.ubuntu_base_image.id
  size           = var.vm_disk_size * 1024 * 1024 * 1024
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.vm_num
  name  = "cloudinit-${count.index}.iso"
  pool  = libvirt_pool.vm_pool.name

  user_data = templatefile("${path.module}/cloud_init.tmpl", {
    hostname     = local.vm_hostname[count.index]
    ssh_pub_key  = file("${pathexpand("~/.ssh/id_rsa.pub")}")
    ip_address   = var.vm_ips[count.index]
    gateway      = var.gateway
    dns_servers  = var.dns_servers
    mac_address  = format("52:54:00:%02x:%02x:01", count.index, count.index)
  })
}

resource "libvirt_domain" "vm" {
  count     = var.vm_num
  name      = local.vm_hostname[count.index]
  memory    = var.vm_memory
  vcpu      = var.vm_vcpu
  
  depends_on = [libvirt_cloudinit_disk.commoninit, libvirt_volume.vm_disk]

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name = "default"
    mac          = format("52:54:00:%02x:%02x:01", count.index, count.index)
    addresses    = [var.vm_ips[count.index]]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
