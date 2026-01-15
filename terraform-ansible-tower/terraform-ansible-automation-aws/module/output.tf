output "ansible_automation_private_ip" {
  description = "The private IP address of the Ansible Automation EC2 instance"
  value       = aws_instance.ansible_automation.*.private_ip
}

output "ansible_automation_alb_dns_name" {
  description = "The DNS name of the Ansible Automation application load balancer"
  value       = aws_lb.test-application-loadbalancer_alb.dns_name
}

output "rds_dbinstance_address" {
  description = "The address (hostname) of the RDS instance"
  value       = aws_db_instance.dbinstance1.address
}

output "rds_dbinstance_endpoint" {
  description = "The connection endpoint, including port"
  value       = aws_db_instance.dbinstance1.endpoint
}
