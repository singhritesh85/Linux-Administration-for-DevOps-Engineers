module "autoscale_alb" {

  source = "../module"
  project_name = var.project_name
  gcp_region = var.gcp_region[1]
  prefix = var.prefix
  ip_range_subnet = var.ip_range_subnet
  ip_public_range_subnet = var.ip_public_range_subnet
  ip_proxy_range_subnet = var.ip_proxy_range_subnet
  machine_type = var.machine_type[0]
  env = var.env[0]

}
