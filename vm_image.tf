variable "machine_name" {
  type = string
}

variable "proxmox_node" {
  type = string
}
variable "template_name" {
  type    = string
  default = "value"
}
variable "vmid" {
  type    = string
  default = "0"
}
variable "description" {
  type    = string
  default = "This will be shown in the notes block."
}
variable "cores" {
  type    = string
  default = "1"
}
variable "memory" {
  type    = string
  default = "1024"
}
variable "onboot" {
  type    = bool
  default = true
}
variable "pool" {
  type    = string
  default = ""
}

variable "disk_size" {
  type    = string
  default = "1G"
}
variable "storage_pool" {
  type    = string
  default = "local-lvm"
}
variable "bridge" {
  type    = string
  default = "vmbr0"
}
variable "ip" {
  type    = string
  default = "192.168.1.254"
}
variable "gateway" {
  type    = string
  default = "192.168.1.1"
}
variable "tags" {
  type    = string
  default = ""
}

variable "hostname" {
  type    = string
  default = ""
}

variable "domain" {
  type    = string
  default = ""
}
# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "config-file" {
  content  = templatefile("${path.module}/templates/template.tftpl", { ssh_key = file("~/.ssh/id_ed25519.pub"), hostname = var.hostname, domain = var.domain })
  filename = "${path.module}/files/config-file-vm-${var.vmid}.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "config-file" {
  connection {
    type        = "ssh"
    private_key = file("~/.ssh/id_rsa")
    host        = var.proxmox_host
    user        = "root"
  }

  provisioner "file" {
    source      = local_file.config-file.filename
    destination = "/var/lib/vz/snippets/config-file-vm-${var.vmid}.cfg"
    # /var/lib/vz/snippets/ needs to be created on host first!
  }
}

resource "proxmox_vm_qemu" "vm" {
  ## Wait for the cloud-config file to exist

  depends_on = [
    null_resource.config-file
  ]
  name = var.machine_name #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  target_node = var.proxmox_node
  clone       = var.template_name

  vmid = var.vmid
  desc = var.description

  # basic VM settings here. agent refers to guest agent
  force_create = false
  agent        = 1
  os_type      = "cloud-init"
  cicustom     = "user=local:snippets/config-file-vm-${var.vmid}.cfg"
  cores        = var.cores
  sockets      = 1
  cpu          = "host"
  memory       = var.memory
  scsihw       = "virtio-scsi-pci"
  onboot       = var.onboot
  pool         = var.pool #The resource pool to which the VM will be added.
  ipconfig0    = "ip=${var.ip}/24,gw=${var.gateway}"
  tags         = var.tags
  full_clone   = true

  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size    = var.disk_size
    type    = "scsi"
    storage = var.storage_pool
  }

  network {
    model  = "virtio"
    bridge = var.bridge
  }

  lifecycle {
    ignore_changes = [
      network,
      tags
    ]
  }
}