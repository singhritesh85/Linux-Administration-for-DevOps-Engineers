module "ansible_automation_platform" {

  source = "../module"
  project_name = var.project_name
  gcp_region = var.gcp_region[1]
  prefix = var.prefix
  ip_range_subnet = var.ip_range_subnet
  ip_public_range_subnet = var.ip_public_range_subnet
  ip_proxy_range_subnet = var.ip_proxy_range_subnet
  instance_count = var.instance_count
  machine_type = var.machine_type[6]
  dns_name = var.dns_name
  dns_zone_visibility = var.dns_zone_visibility[0]
  enable_logging = var.enable_logging[0] 
  dnssec_state = var.dnssec_state[0] 
  tier = var.tier[0]
  database_version = var.database_version[6]
  env = var.env[0]

}
