terraform {
  required_version = "~> 1.5.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
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
  pm_tls_insecure = var.pm_tls_insecure

  pm_user             = var.pm_user
  pm_password         = var.pm_password
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
}





resource "proxmox_vm_qemu" "test_server" {
  count       = var.vm_count # just want 1 for now, set to 0 and apply to destroy VM
  vmid        = var.vm_count > 1 ? var.vm_id + count.index : var.vm_id
  name        = var.vm_count > 1 ? "cf-pve-cl-01-flatcar-${count.index + 1}" : "cf-pve-cl-01-flatcar"
  
  target_node = var.target_node


  clone      = var.template_name
  full_clone = false
  clone_wait = 0


  args = "-fw_cfg name=opt/org.flatcar-linux/config,file=/etc/pve/local/ignition/${var.vm_count > 1 ? var.vm_id + count.index : var.vm_id}.ign"
  desc = "data:application/vnd.coreos.ignition+json;charset=UTF-8;base64,${base64encode(data.ct_config.ignition_json[count.index].rendered)}"


  agent = 1
  timeouts {
    create  = "60s"
    update  = "60s"
    default = "120s"
  }

  define_connection_info = false # ssh connection info is defined in the ignition configuration


  bios = "ovmf" 


  os_type = var.os_type 
  qemu_os = var.os_type  

  cores   = var.cores
  sockets = 1
  cpu     = var.cpu
  memory  = var.memory
  onboot  = true
  scsihw  = "virtio-scsi-single"


  network {
    model  = "virtio"
    bridge = var.network_bridge
    tag    = var.network_tag
  }

  lifecycle {
    prevent_destroy       = false # this resource should be immutable **and** disposable
    create_before_destroy = false
    ignore_changes        = [
      disk # the disk is provisioned in the template and inherited (but not defined here]
    ]
    replace_triggered_by = [
      null_resource.node_replace_trigger[count.index].id
    ]
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