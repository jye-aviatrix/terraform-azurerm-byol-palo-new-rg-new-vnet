variable "region" {
  type        = string
  description = "Provide region of the resources"
}

variable "zone" {
  type = number
  description = "Provide the Availability zone to deploy Palo VM into"
}

variable "resource_group_name" {
  type        = string
  description = "Provide Resoruce Group Name for Palo"
}


variable "palo_vm_name" {
  type = string
  description = "Provide Palo BYOL VM name"
}

variable "mgmt_subnet_id" {
  type = string
  description = "Provide mgmt subnet ID"
}

variable "untrust_subnet_id" {
  type = string
  description = "Provide untrust subnet ID"
}

variable "trust_subnet_id" {
  type = string
  description = "Provide trust subnet ID"
}

variable "palo_size" {
  type = string
  description = "Provide Palo VM Size"
}

variable "admin_username" {
  type = string
  description = "Provide Palo default user name"
}
variable "admin_password" {
  type = string
  description = "Provide Palo default password"
}

variable "palo_version" {
  type = string
  description = "Provide Palo BYOL VM version"
}

variable "storage_account" {
  type = string
  description = "Provide bootstrap Storage Account name"
}

variable "access_key" {
  type = string
  description = "Provide bootstrap Storage Account access key"
}

variable "file_share" {
  type = string
  description = "Provide bootstrap Storage Account file share name"
}