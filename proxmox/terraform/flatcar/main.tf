terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.12.0"
    }

    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_tls_insecure = true
  

  pm_api_token_id     = var.token_id
  pm_api_token_secret = var.token_secret
}

resource "proxmox_cloud_init_disk" "ci" {
  count     = var.vm_count # just want 1 for now, set to 0 and apply to destroy VM
  name      = var.vm_count > 1 ? "cf-pve-cl-01-flatcar-${count.index + 1}" : "cf-pve-cl-01-flatcar"
  pve_node  = var.target_node
  storage   = "NAS"

  meta_data = yamlencode({
    instance_id    = sha1(var.vm_count > 1 ? "cf-pve-cl-01-flatcar-${count.index + 1}" : "cf-pve-cl-01-flatcar")
    local-hostname = var.vm_count > 1 ? "cf-pve-cl-01-flatcar-${count.index + 1}" : "cf-pve-cl-01-flatcar"
  })

  user_data = data.ct_config.ignition_json[count.index].rendered

}

resource "proxmox_vm_qemu" "test_server" {
  count       = var.vm_count
  name        = var.vm_count > 1 ? "cf-pve-cl-01-flatcar-${count.index + 1}" : "cf-pve-cl-01-flatcar"
  target_node = var.target_node
  desc = "data:application/vnd.coreos.ignition+json;charset=UTF-8;base64,${base64encode(data.ct_config.ignition_json[count.index].rendered)}"

  agent = 1
  define_connection_info = false 
  bios = "seabios" 
  os_type = "host"

  cores   = var.cores
  sockets = 1
  cpu     = var.cpu
  memory  = var.memory
  onboot  = true
  scsihw  = "virtio-scsi-single"

  clone      = var.template_name
  full_clone = false
  clone_wait = 0

    disks {
        scsi {
            scsi0 {
                disk {
                    discard            = true
                    emulatessd         = true
                    iothread           = true
                    size               = 32
                    storage            = "Ceph"
                }
            }
        }
        ide {
            ide3 {
                cdrom  {
                    iso = "${proxmox_cloud_init_disk.ci[count.index].id}"
                 }
            }
        }
    }

  network {
    model  = "virtio"
    bridge = var.network_bridge
    tag    = var.vlan
  }

}


data "ct_config" "ignition_json" {
  count   = var.vm_count
  content = templatefile(var.butane_conf, {
    "vm_id"          = var.vm_count > 1 ? var.vm_id + count.index : var.vm_id
    "vm_name"        = var.vm_count > 1 ? "${var.name}-${count.index + 1}" : var.name
    "vm_count"       = var.vm_count,
    "vm_count_index" = count.index,
  })
  strict       = false
  pretty_print = true

  snippets = [
    for snippet in var.butane_conf_snippets : templatefile(var.butane_conf, {
      "vm_id"          = var.vm_count > 1 ? var.vm_id + count.index : var.vm_id
      "vm_name"        = var.vm_count > 1 ? "${var.name}-${count.index + 1}" : var.name
      "vm_count"       = var.vm_count,
      "vm_count_index" = count.index,
    })
  ]
}


resource "null_resource" "node_replace_trigger" {
  count   = var.vm_count
  triggers = {
    "ignition" = "${data.ct_config.ignition_json[count.index].rendered}"
  }
}
