module "ansible_automation" {

  source = "../module"
  prefix = var.prefix
  location = var.location[1]
  
  env = var.env[0]

  ############################ Azure VM ################################# 

  vm_size = var.vm_size[2]
  vm_count = var.vm_count
  availability_zone = var.availability_zone
  static_dynamic = var.static_dynamic
  disk_size_gb = var.disk_size_gb
  extra_disk_size_gb = var.extra_disk_size_gb
  computer_name  = var.computer_name
  admin_username = var.admin_username
  admin_password = var.admin_password

  ############################ Create the Azure Application Gateway #################################

  ssl_certificate_password = var.ssl_certificate_password

  ############################ Create PostgreSQL Flexible Servers ###################################

  psql_server_admin_username = var.psql_server_admin_username

}
