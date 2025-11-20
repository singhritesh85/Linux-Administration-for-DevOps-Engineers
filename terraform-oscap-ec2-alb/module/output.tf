output "EC2_Instance_Webserver_Private_IP_Address" {
  description = "Private IP Address of Webserver EC2 Instance"
  value = aws_instance.webserver.private_ip
}

output "EC2_Instance_Ansible_controller_Private_IP_Address" {
  description = "Private IP Address of Ansible Controller EC2 Instance"
  value = aws_instance.ansible_controller.private_ip
}

output "EC2_Instance_OSCAP_Private_IP_Addresses" {
  description = "Private IP Address of OSCAP EC2 Instances"
  value = aws_instance.oscap_ec2_instance[*].private_ip
}

output "Webserver_ALB_DNS_Name" {
  description = "The DNS name of the Webserver Application Load Balancer"
  value = aws_lb.test-application-loadbalancer-webserver.dns_name
}
