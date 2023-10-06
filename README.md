# terraform-proxmox-vm-image
This repository creates a clone from a existing VM template

## Usage

* Install all relevant providers:
```shell
terraform init
```

* Create execution plan
```shell
terraform plan
```

* Apply changes
```shell
terraform apply
```

## Configuration

Terraform has several options to set variable values, see the [docs](https://developer.hashicorp.com/terraform/enterprise/workspaces/variables/managing-variables).

Following values are to be set:

```yaml
proxmox_api_url          = "https://PROXMOX.URL:8006/api2/json" # Your Proxmox IP Address
proxmox_api_token_id     = "USERNAME@pve!TOKEN"             # API Token ID
proxmox_api_token_secret = "TOKEN"
proxmox_host             = "PROXMOX.URL"
```
Following options are to be adapted as per your needs:

```yaml
machine_name  = "machine_name"
proxmox_node  = "pve"
template_name = "template_name"
vmid          = "123"
description   = "some description about the VM seen in the notes field."
cores         = "4"
memory        = "4096"
pool          = "name-your-pool"
disk_size     = "10G"
bridge        = "vmbr123"
ip            = "192.168.178.123"
gateway       = "192.168.178.1"
tags          = "add some tags here"
hostname      = "hostname ot the vm"
domain        = "domain name"
```