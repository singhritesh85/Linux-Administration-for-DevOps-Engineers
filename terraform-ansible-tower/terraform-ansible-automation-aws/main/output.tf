output "Ansible_automation_ec2_private_ip_and_alb_dns_name" {
  description = "Details of the Ansible-Automation Private IP and ansible-automation ALB DNS Name"
  value       = "${module.ansible_automation}"
}
