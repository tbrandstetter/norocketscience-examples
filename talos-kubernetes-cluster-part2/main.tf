# Control Plane
# resource "proxmox_vm_qemu" "controlplane" {
#   name        = "talos-cp-${count.index + 1}"
#   target_node = "proxmox2"
#   count       = 1
#   bios        = "ovmf"
#   agent       = 1
#   machine     = "q35"
#   skip_ipv6   = true

#   startup_shutdown {
#     order             = 3
#     shutdown_timeout  = -1
#     startup_delay     = -1
#   }

#   start_at_node_boot = true
#   cpu {
#     cores = 4
#     sockets = 1
#     type = "host"
#   }
#   memory   = 6144
#   scsihw   = "virtio-scsi-pci"
#   boot     = "order=scsi0;ide2"

#   disks {
#     ide {
#       ide2 {
#         cdrom {
#           iso = "local:iso/metal-amd64-secureboot.iso"
#         }
#       }
#     }
#     scsi {
#       scsi0 {
#         disk {
#           size     = "64G"
#           storage  = "data"
#         }
#       }
#     }
#   }

#   efidisk {
#     efitype = "4m"
#     storage = "data"
#   }

#   network {
#     model  = "virtio"
#     bridge = "vmbr3"
#     firewall = false
#     link_down = false
#     id = 1
#   }

#   rng {
#     period = 0
#     source = "/dev/urandom"
#   }

#   vga {
#     type   = "std"
#   }
# }

# Worker
# resource "proxmox_vm_qemu" "worker" {
#   name        = "talos-worker-${count.index +1}"
#   target_node = "proxmox2"
#   count       = 1
#   bios        = "ovmf"
#   agent       = 1
#   machine     = "q35"
#   skip_ipv6   = true

#   startup_shutdown {
#     order             = 4
#     shutdown_timeout  = -1
#     startup_delay     = -1
#   }

#   start_at_node_boot = true
#   cpu {
#     cores = 4
#     sockets = 1
#     type = "host"
#   }
#   memory   = 8172
#   scsihw   = "virtio-scsi-pci"
#   boot     = "order=scsi0;ide2"

#   disks {
#     ide {
#       ide2 {
#         cdrom {
#           iso = "local:iso/metal-amd64-secureboot.iso"
#         }
#       }
#     }
#     scsi {
#       scsi0 {
#         disk {
#           size     = "100G"
#           storage  = "data"
#         }
#       }
#     }
#   }

#   efidisk {
#     efitype = "4m"
#     storage = "data"
#   }

#   network {
#     model  = "virtio"
#     bridge = "vmbr3"
#     firewall = false
#     link_down = false
#     id = 1
#   }

#   rng {
#     period = 0
#     source = "/dev/urandom"
#   }

#   vga {
#     type   = "std"
#   }
# }

# PFSense Firewall
resource "proxmox_vm_qemu" "firewall" {
  name        = "pfsense-${count.index +1}"
  target_node = "proxmox2"
  count       = 1
  bios        = "ovmf"
  machine     = "q35"
  skip_ipv6   = true

  startup_shutdown {
    order             = 1
    shutdown_timeout  = -1
    startup_delay     = -1
  }

  start_at_node_boot = true
  cpu {
    cores = 1
    sockets = 1
    type = "host"
  }
  memory   = 1024
  boot     = "order=virtio0;ide2"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/pfSense-CE-2.7.2-RELEASE-amd64.iso"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size     = "10G"
          storage  = "data"
          iothread = true
        }
      }
    }
  }

  efidisk {
    efitype = "4m"
    storage = "data"
  }

  # WAN
  network {
    model  = "virtio"
    bridge = "vmbr0"
    firewall = false
    link_down = false
    id = 0
  }

  # MGMT
  network {
    model  = "virtio"
    bridge = "vmbr1"
    firewall = false
    link_down = false
    id = 1
  }

  # DMZ
  network {
    model  = "virtio"
    bridge = "vmbr2"
    firewall = false
    link_down = false
    id = 2
  }

  # SRV
  network {
    model  = "virtio"
    bridge = "vmbr3"
    firewall = false
    link_down = false
    id = 3
  }

  rng {
    period = 0
    source = "/dev/urandom"
  }

  vga {
    type   = "std"
  }
}

# Bastion Host
resource "proxmox_vm_qemu" "bastion" {
  name        = "bastion"
  target_node = "proxmox2"
  count       = 1

  clone = "ubuntu-24.04-cloud-init-template"

  startup_shutdown {
    order             = 2
    shutdown_timeout  = -1
    startup_delay     = -1
  }

  os_type  = "cloud-init"
  start_at_node_boot = true
  cpu {
    cores = 2
    sockets = 1
    type = "host"
  }
  memory   = 4096
  scsihw   = "virtio-scsi-single"
  boot     = "order=scsi0"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "data"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size     = "50G"
          storage  = "data"
          iothread = true
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
    id = 0
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0 = "ip=192.168.100.11/24,gw=192.168.100.1"
  nameserver = "192.168.100.1"
  searchdomain = "mgmt.lab.internal"
  cipassword  = "ubuntu"
  cicustom    = "vendor=local:snippets/ci-custom.yml"
  ciupgrade   = true 
}

# HAProxy Ingress Host
resource "proxmox_vm_qemu" "haproxy-ingess" {
  name        = "haproxy-ingress-1"
  target_node = "proxmox2"
  count       = 1

  clone = "ubuntu-24.04-cloud-init-template"

  startup_shutdown {
    order             = 5
    shutdown_timeout  = -1
    startup_delay     = -1
  }

  os_type  = "cloud-init"
  start_at_node_boot = true
  cpu {
    cores = 2
    sockets = 1
    type = "host"
  }
  memory   = 4096
  scsihw   = "virtio-scsi-single"
  boot     = "order=scsi0"

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "data"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size     = "50G"
          storage  = "data"
          iothread = true
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr2"
    id = 0
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0 = "ip=172.16.100.10/24,gw=172.16.100.1"
  nameserver = "172.16.100.1"
  searchdomain = "srv.lab.internal"
  cipassword  = "ubuntu"
  cicustom    = "vendor=local:snippets/ci-custom.yml"
  ciupgrade   = true 
}


# Management Client
resource "proxmox_vm_qemu" "mgmt-client" {
  name        = "mgmt-client"
  target_node = "proxmox2"
  count       = 1
  bios        = "ovmf"
  agent       = 1
  machine     = "q35"
  skip_ipv6   = true

  startup_shutdown {
    order             = 6
    shutdown_timeout  = -1
    startup_delay     = -1
  }

  start_at_node_boot = true
  cpu {
    cores = 2
    sockets = 1
    type = "host"
  }
  memory   = 4096
  scsihw   = "virtio-scsi-pci"
  boot     = "order=scsi0;ide2"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/ubuntu-24.04.3-desktop-amd64.iso"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size     = "64G"
          storage  = "data"
        }
      }
    }
  }

  efidisk {
    efitype = "4m"
    storage = "data"
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
    firewall = false
    link_down = false
    id = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr4"
    firewall = false
    link_down = false
    id = 2
  }

  rng {
    period = 0
    source = "/dev/urandom"
  }

  vga {
    type   = "virtio"
    memory = 128
  }
}