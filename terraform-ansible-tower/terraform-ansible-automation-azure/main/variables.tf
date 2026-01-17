variable "prefix" {
  type = string
  description = "Provide the Prefix Name" 
}

variable "location" {
  type = list
  description = "Provide the Location for Azure Resource to be created"
}

variable "env" {
  type = list
  description = "Provide the Environment for AKS Cluster"
}

################################################################# Variables for Azure VM ##############################################################

variable "vm_size" {
  type = list
  description = "Provide the Size of the Azure VM"
}

variable "vm_count" {
  type = number
  description = "Provide the number of Azure VMs to be created"
}

variable "availability_zone" {
  type = list
  description = "Provide the Availability Zone into which the VM to be created"
}

variable "static_dynamic" {
  type = list
  description = "Select the Static or Dynamic"
}

variable "disk_size_gb" {
  type = number
  description = "Provide the Disk Size in GB"
}

variable "extra_disk_size_gb" {
  type = number
  description = "Provide the Size of Extra Disk to be Attached"
}

variable "computer_name" {
  type = string
  description = "Provide the Hostname"
}

variable "admin_username" {
  type = string
  description = "Provid the Administrator Username"
}

variable "admin_password" {
  type = string
  description = "Provide the Administrator Password"
}

################################################### Variables to create Azure Application Gateway ######################################################

variable "ssl_certificate_password" {
  type = string
  description = "Provide the Password for SSL Certificate of Azure Application Gateway"
}

################################################## Username and Password for Azure PostgreSQL Flexible Servers #########################################

variable "psql_server_admin_username" {
  type = string
  description = "Provide the username for PostgreSQL Flexible Server"
}
