output "gcp_oscap_vm_instance_private_ip_address" {
  value = google_compute_instance.vm_instance[*].network_interface[*].network_ip
}

output "gcp_oscap_vm_instance_public_ip_address" {
  value = google_compute_address.vm_static_ip[*].address
}

output "gcp_httpd_vm_instance_private_ip_address" {
  value = google_compute_instance.vm_instance-httpd.network_interface[0].network_ip
}

output "gcp_httpd_vm_instance_public_ip_address" {
  value = google_compute_address.vm_static_ip_httpd.address
}

output "gcp_ansible_vm_instance_private_ip_address" {
  value = google_compute_instance.vm_instance_ansible.network_interface[0].network_ip
}

output "gcp_ansible_vm_instance_public_ip_address" {
  value = google_compute_address.vm_static_ip_ansible.address
}

output "gcp_alb_static_ip" {
  value = google_compute_global_address.alb_static_ip.address
}
