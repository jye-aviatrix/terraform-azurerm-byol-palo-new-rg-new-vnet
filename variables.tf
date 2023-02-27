variable "region" {
  type        = string
  default     = "East US"
  description = "Provide region of the resources"
}

variable "resource_group_name" {
  type        = string
  default     = "palo-byol"
  description = "Provide Resoruce Group Name for Palo"
}

variable "vnet_name" {
  type        = string
  default     = "palo-vnet"
  description = "Provide vNet name for Palo"
}

variable "vnet_cidr" {
  type        = string
  default     = "10.0.16.0/24"
  description = "Provide vNet address space"
}

variable "mgmt_cidr" {
  type        = string
  default     = "10.0.16.0/26"
  description = "Provide mgmt subnet CIDR"
}

variable "untrust_cidr" {
  type        = string
  default     = "10.0.16.64/26"
  description = "Provide untrust (WAN) subnet CIDR"
}

variable "trust_cidr" {
  type        = string
  default     = "10.0.16.128/26"
  description = "Provide trust (LAN) subnet CIDR"
}

variable "palo_vm_name" {
  type = string
  default = "palo-byol-vm"
  description = "Provide Palo BYOL VM name"
}

variable "palo_version" {
  type = string
  default = "10.1.4"
  description = "Provide Palo BYOL VM version"
}

variable "palo_size" {
  type = string
  default = "Standard_D3_v2"
  description = "Provide Palo VM Size"
}

variable "admin_username" {
  type = string
  default = "fwadmin"
  description = "Provide Palo default user name"
}
variable "admin_password" {
  type = string
  default = "sb%BSu/.T+j3"
  description = "Provide Palo default password"
}