variable "name" {
  type        = string
  default     = "Flatcar-Linux"
  description = "The base name of the VM"
}

variable "butane_conf" {
  type        = string
  description = "YAML Butane configuration for the VM"
}
variable "butane_conf_snippets" {
  type        = list(string)
  default     = []
  description = "Additional YAML Butane configuration(s) for the VM"
}
variable "target_node" {
  description = "The name of the target proxmox node"
  type        = string
  default     = "pve-02"
}
variable "storage" {
  description = "The name of the storage used for storing VM images"
  type        = string
  default     = "Ceph"
}

variable "vm_count" {
  description = "The number of VMs to provision"
  type        = number
  default     = 1
}
variable "template_name" {
  description = "The name of the Proxmox Flatcar template VM"
  type    = string
  default = "flatcar_qemu"
}
variable "vm_id" {
  type    = number
  default = 0
}
variable "cores" {
  type    = number
  default = 2
}
variable "cpu" {
  type        = string
  default     = "host"
  description = "e.g. x86-64-v2-AES"
}
variable "memory" {
  type    = number
  default = 4096
}
variable "network_bridge" {
  type    = string
  default = "vmbr2"
}
variable "network_tag" {
  type    = number
  default = 9
}
variable "os_type" {
  type        = string
  default     = "l26"
  description = "The short OS name identifier"
}

variable "os_type_name" {
  type        = string
  default     = "Linux 2.6 - 6.X Kernel"
  description = "os_type_name='Linux 2.6 - 6.X Kernel'"
}


variable "pm_api_url" {
  description = "The FQDN and path to the API of the proxmox server e.g. https://example.com:8006/api2/json"
  type        = string
}

variable "pm_api_token_id" {
  description = "user@pam!token_id"
  type        = string
  default     = "root@pam"
}


/*
  The API secret from the proxmox datacenter.

  The identity must have the permission 'PVEVMAdmin' to the correct path ('/'). Due to possible issues
  in the API and hoe authorisation is performed, the

  With the incorrect permissions, the following error is generated:
      Error: user greg@pam has valid credentials but cannot retrieve user list, check privilege
      separation of api token
  Which corresponds to the following GET from /var/log/pveproxy/access.log
      GET /api2/json/access/users?full=1

  Required Privileges
  ===================

  user must be 'root@pam'                            <=== ugly
  userid-group, Sys.Audit -> GET users

  see
    - https://forum.proxmox.com/threads/root-pam-token-api-restricted.83866/
    - https://pve.proxmox.com/pve-docs/api-viewer/index.html#/access/users
    - https://github.com/Telmate/terraform-provider-proxmox/issues/385
    - https://bugzilla.proxmox.com/show_bug.cgi?id=4068
*/
variable "pm_api_token_secret" {
  description = "secret hash"
  type        = string
  sensitive   = true
  default     = ""
}

variable "pm_user" {
  description = "A username for password based authentication of the Proxmox API"
  type        = string
  default     = ""
}

variable "pm_password" {
  description = "A password for password based authentication of the Proxmox API"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = ["flatcar"]
}