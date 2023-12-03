resource "proxmox_virtual_environment_vm" "controllers" {
  for_each    = local.controllers
  name        = each.key
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu", "controller"]

  node_name = var.proxmox_host
  vm_id     = each.value.vm_id

  agent {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
      initialization
    ]
  }

  cpu {
    type = "host"
    cores = each.value.cpu_cores
  }

  tablet_device = false

  initialization {
    datastore_id = "vm2"
    user_data_file_id = proxmox_virtual_environment_file.controllers[each.key].id
    ip_config {
        ipv4 {
            address = "dhcp"
        }
    }

  }

  disk {
    datastore_id = "vm2"
    interface = "scsi0"
    size = each.value.disk_size
    file_format = "raw"
  }

  memory {
    dedicated = each.value.memory
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  clone {
    vm_id = 9000
    full = true
    retries = 3
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
