resource "proxmox_vm_qemu" "k3s_server" {
  count             = 1
  name              = "kubernetes-master-${count.index}"
  target_node       = "homelab"

  clone             = "ubuntu-1804LTS-template"

  os_type           = "cloud-init"
  cores             = 1
  sockets           = "1"
  cpu               = "host"
  memory            = 1024
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"

  disk {
    id              = 0
    size            = 20
    type            = "scsi"
    storage         = "data2"
    storage_type    = "lvm"
    iothread        = true
  }

  network {
    id              = 0
    model           = "virtio"
    bridge          = "vmbr0"
  }

  lifecycle {
    ignore_changes  = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0         = "ip=192.168.2.1${count.index + 1}/24,gw=192.168.2.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "k3s_agent" {
  count             = 2
  name              = "kubernetes-node-${count.index}"
  target_node       = "homelab"

  clone             = "ubuntu-1804LTS-template"

  os_type           = "cloud-init"
  cores             = 1
  sockets           = "1"
  cpu               = "host"
  memory            = 1024
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"

  disk {
    id              = 0
    size            = 20
    type            = "scsi"
    storage         = "data2"
    storage_type    = "lvm"
    iothread        = true
  }

  network {
    id              = 0
    model           = "virtio"
    bridge          = "vmbr0"
  }

  lifecycle {
    ignore_changes  = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0         = "ip=192.168.2.1${count.index + 1}/24,gw=192.168.2.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "storage" {
  count             = 1
  name              = "storage-node-${count.index}"
  target_node       = "homelab"

  clone             = "ubuntu-1804LTS-template"

  os_type           = "cloud-init"
  cores             = 1
  sockets           = "1"
  cpu               = "host"
  memory            = 1024
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"

  disk {
    id              = 0
    size            = 20
    type            = "scsi"
    storage         = "data2"
    storage_type    = "lvm"
    iothread        = true
  }

  network {
    id              = 0
    model           = "virtio"
    bridge          = "vmbr0"
  }

  lifecycle {
    ignore_changes  = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0         = "ip=192.168.2.1${count.index + 1}/24,gw=192.168.2.1"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

# Ansible inventory
resource "ansible_host" "k3s_master" {
  count              = 1
  inventory_hostname = "kubernetes-master-${count.index}"
  vars = {
    ansible_host = "192.168.2.1${count.index + 1}"
  }
  groups              = ["k3s_master"]
}

resource "ansible_host" "k3s_agent" {
  count              = 2
  inventory_hostname = "kubernetes-node-${count.index}"
  vars = {
    ansible_host = "192.168.2.1${count.index + 1}"
  }
  groups              = ["k3s_agents"]
}

resource "ansible_host" "storage" {
  count              = 1
  inventory_hostname = "storage-node-${count.index}"
  vars = {
    ansible_host = "192.168.2.1${count.index + 1}"
  }
  groups              = ["storage"]
}
