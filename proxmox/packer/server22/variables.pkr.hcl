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
