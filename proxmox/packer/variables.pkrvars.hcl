proxmox_api_url = "https://{{pve_node.ip}}:8006/api2/json"
proxmox_api_token_id = "{{pve_api_id}}"
proxmox_api_token_secret = "{{pve_api_token}}"
proxmox_node = "{{pve_node}}"
proxmox_insecure_skip_tls_verify = true

ssh_password = "{{ssh_password}}"
ssh_certificate = "~/.ssh/default_linux_login"
timezone = "Europe/London"

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN7jYmqul1p4wjP7Xr4xgsBf9VF2XtkqsD2NWRrEvHcq eddsa-key-20250603"

vm_cores = "4"
vm_memory = "4096"
vm_disk_size = "10G"
vm_storage_pool = "Ceph"
vm_disk_format = "raw"


windows_edition = "datacenter" # can be datacenter or standard
template = "core" # can be desktop or core

iso_storage_pool = "NAS"
almalinux9_iso = "NAS:iso/AlmaLinux-9.4-x86_64-dvd.iso"
almalinux10_iso = "NAS:iso/alma10.iso"
ubuntu2404_iso = "NAS:iso/ubuntu-24.04-live-server-amd64(1).iso"
server22_iso = "NAS:iso/Server22.iso"
