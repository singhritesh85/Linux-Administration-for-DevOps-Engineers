output "Ansible_automation_Azure_VMs_public_and_private_ip_postgresql_flible_servers_endpoint_and_application_gateway_public_ip" {
  description = "Details of the Ansible-Automation Azure VMs Public IP, VMs Private IP, PostgreSQL Flexible Servers endpoint, ansible-automation ALB DNS Name"
  value       = "${module.ansible_automation}"
}
