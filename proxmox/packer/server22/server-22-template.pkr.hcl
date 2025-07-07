packer {
  required_plugins {
    windows-update = {
      version = "0.14.3"
      source = "github.com/rgl/windows-update"
    }
    proxmox = {
      version = "1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">=1.1.3"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "template" {
  type = string 
  default = "desktop" 
  description = "Template type, can be desktop or core"
  validation {
    condition = (var.template == "desktop") || (var.template == "core")
    error_message = "Should be desktop or core."
  }
}

variable "image_index" {
  type = map(string)
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "proxmox_node" {
    type = string
}

variable "ssh_password" {
    type = string
    sensitive = true
}
variable "vm_cores" {
    type = string
    description = "Number of CPU cores for the VM"
}

variable "vm_memory" {
    type = string
    description = "Amount of memory for the VM in MB"
}

variable "vm_disk_size" {
    type = string
    description = "Disk size for the VM"
}

variable "vm_storage_pool" {
    type = string
    description = "Storage pool for VM disk"
}

variable "vm_disk_format" {
    type = string
    description = "Disk format (raw, qcow2, etc.)"
}

variable "iso_storage_pool" {
    type = string
    description = "Storage pool for ISO files"
}

variable "server22_iso" {
    type = string
    description = "Path to the AlmaLinux 10 ISO file"
}

variable "cdrom_drive" {
    type = string
    default = "D:"
}


source "proxmox-iso" "windows2022" {
  insecure_skip_tls_verify  = "true"
  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  node = "${var.proxmox_node}"

  template_name = "templ-win2022-${var.template}"
  template_description = "Created on: ${timestamp()}"
  vm_name = "win22-${var.template}"
  os = "win11"

  cores = "${var.vm_cores}"
  memory = "${var.vm_memory}"
  cpu_type = "host"
  bios = "ovmf"
  machine = "q35"

  efi_config {
    efi_storage_pool = "${var.vm_storage_pool}"
    pre_enrolled_keys = true
    efi_format = "raw"
    efi_type = "4m"
  }

  disks {
      disk_size = "${var.vm_disk_size}"
      format = "${var.vm_disk_format}"
      storage_pool = "${var.vm_storage_pool}"
      type = "scsi"

  }

  network_adapters {
      model = "virtio"
      bridge = "vmbr2"
      firewall = "false"
  }

  cloud_init = false
  cloud_init_storage_pool = "${var.vm_storage_pool}"

  boot_iso {
      iso_file = "${var.server22_iso}"
      iso_storage_pool = "${var.iso_storage_pool}"
      unmount = true
  }


  additional_iso_files {
    cd_files = ["./server22/drivers/*", "./server22/scripts/ConfigureRemotingForAnsible.ps1","./server22/apps/virtio-win-guest-tools.exe"]
    cd_content = {
      "autounattend.xml" = templatefile("./template/autounattend.pkrtpl", {password = var.ssh_password, cdrom_drive = var.cdrom_drive, index = lookup(var.image_index, var.template, "desktop")})
    }
    cd_label = "Unattend"
    iso_storage_pool = var.iso_storage_pool
    unmount = true
    device = "sata0"
  }
  
  scsi_controller = "virtio-scsi-pci"
  



  # WinRM
  communicator          = "winrm"
  winrm_username        = "Ansible"
  winrm_password        = var.ssh_password
  winrm_timeout         = "12h"
  winrm_port            = "5986"
  winrm_use_ssl         = true
  winrm_insecure        = true

  # Boot
  boot_wait = "7s"
  boot_command = [
    "<enter>setup.exe /unattend:${var.cdrom_drive}\\autounattend.xml"
  ]

}

build {
  name = "Proxmox Build"
  sources = ["source.proxmox-iso.windows2022"]

  provisioner "windows-restart" {
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 25
  }

  provisioner "ansible" {
    playbook_file     = "./server22/ansible/main.yml"
    use_proxy = false
    skip_version_check = true
    user              = "ansible"
    extra_arguments = [
      "-e", "ansible_connection=winrm",
      "-e", "ansible_winrm_server_cert_validation=ignore"
    ]
  }
}
