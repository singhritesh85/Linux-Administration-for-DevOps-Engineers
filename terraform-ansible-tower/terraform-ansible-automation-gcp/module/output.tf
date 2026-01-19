output "gcp_ansible_automation_vm_instance_private_ip_address" {
  value = google_compute_instance.vm_instance[*].network_interface[*].network_ip
}

output "gcp_ansible_automation_vm_instance_public_ip_address" {
  value = google_compute_address.vm_static_ip[*].address
}

output "gcp_alb_static_ip" {
  value = google_compute_global_address.alb_static_ip.address
}

output "db_instance_name" {
  value = google_sql_database_instance.db_instance.name
}

output "db_connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}

output "db_instance_private_ip_address" {
  value = google_sql_database_instance.db_instance.private_ip_address
}

output "zone_name" {
  value = google_dns_managed_zone.dexter_public_zone.name
}

output "zone_dns_name" {
  value = google_dns_managed_zone.dexter_public_zone.dns_name
}

output "dns_zone_nameservers" {
  value = google_dns_managed_zone.dexter_public_zone.name_servers
}
