resource "null_resource" "download_image" {
  provisioner "local-exec" {
    command = "test -f ${path.module}/${var.cloud_image_name} || wget -O ${path.module}/${var.cloud_image_name} ${var.cloud_image_url}"
  }
}

resource "libvirt_volume" "ubuntu_img" {
  name   = var.cloud_image_name
  pool   = "default"
  source = "${path.module}/${var.cloud_image_name}"
  format = "qcow2"

  depends_on = [null_resource.download_image]
}

resource "libvirt_volume" "vm_disk" {
  name           = "${var.vm_name}.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_img.id
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name      = "${var.vm_name}-cloudinit.iso"
  pool      = "default"
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud-init/user_data.tpl")

  vars = {
    username          = var.username
    password          = var.password
    hostname          = var.vm_name
    interface1_name   = "ens3"
    interface2_name   = "ens4"
    interface1_config = indent(6, yamlencode(var.vm_interface1_config))
    interface2_config = indent(6, yamlencode(var.vm_interface2_config))
  }
}

resource "libvirt_domain" "vm" {
  name      = var.vm_name
  memory    = var.memory
  vcpu      = var.vcpu
  autostart = true

  network_interface {
    bridge = var.bridge1_name
  }

  network_interface {
    bridge = var.bridge2_name
  }

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
