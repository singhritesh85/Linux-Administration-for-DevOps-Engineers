variable "project_name" {
  description = "Provide the project name in GCP Account"
  type = string
}

variable "gcp_region" {
  description = "Provide the GCP Region in which Resources to be created"
  type = list
}

variable "prefix" {
  description = "Provide the prefix used for the project"
  type = string
}

variable "ip_range_subnet" {
  description = "Provide the IP range for Private Subnet"
  type = string 
}

variable "ip_public_range_subnet" {
  description = "Provide the IP range for Public Subnet"
  type = string
}

variable "ip_proxy_range_subnet" {
  description = "Provide the IP range for Proxy Subnet will be used by GCP ALB"
  type = string
}

variable "instance_count" {
  description = "Provide the number of GCP VM Instances to be created"
  type = number
}

variable "machine_type" {
  description = "Provide the Machine Type for VM Instances"
  type = list
}

variable "dns_name" {
  description = "Provide the name of the Cloud DNS Zone"
  type = string
}

variable "dns_zone_visibility" {
  description = "Select the DNS Zone Visibility between Public and Private"
  type = list
}

variable "enable_logging" {
  description = "Select do you want to enable or disable the logging"
  type = list
}

variable "dnssec_state" {
  description = "Select do you want to enable or disable the dnssec"
  type = list
}

variable "tier" {
  description = "Provide the Machine Type for VM Instances"
  type = list  
}

variable "database_version" {
  description = "Provide the database version DB Instance"
  type = list
}

variable "db_schema_name" {
  description = "Provide the DB Schema name for GCP Cloud SQL PostgreSQL"
  type = string
}

variable "username" {
  description = "Provide the Username for GCP Cloud SQL PostgreSQL"
  type = string
}

variable "env" {
  type = list
  description = "Provide the Environment for Cloud Instrastructure"
}
