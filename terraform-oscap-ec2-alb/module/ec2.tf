############################################################# Webserver httpd EC2 Instance ##################################################################
# Security Group for httpd webserver
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Security Group for webserver ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.webserver_alb.id]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver-sg"
  }
}

resource "aws_instance" "webserver" {
  ami           = var.provide_ami["us-east-2-amazonlinux2023"]
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.webserver.id]      ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                                 ###aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp2"
    volume_size=var.disk_size
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
    tags={
      Snapshot = "true"
      Environment = var.env 
      Name="${var.name}-root-volume"
    }
  }
  iam_instance_profile = "Administrator_Access"    ###aws_iam_instance_profile.ec2_instance_profile.name   ### IAM Role to be attached to EC2
  user_data = file("user_data_webserver.sh")

  lifecycle{
    prevent_destroy=false
    ignore_changes=[ ami ]
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  metadata_options { #Enabling IMDSv2
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  tags={
    Name="${var.name}"
    Environment = var.env
  }

}

resource "aws_eip" "eip_associate_webserver" {
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_webserver" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.webserver.id
  allocation_id = aws_eip.eip_associate_webserver.id
}

########################################################## Ansible Controller EC2 Instance ###############################################################
# Security Group for Ansible Controller
resource "aws_security_group" "ansible_controller" {
  name        = "ansible-controller"
  description = "Security Group for ansible controller"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ansible-Conroller-sg"
  }
}

resource "aws_instance" "ansible_controller" {
  ami           = var.provide_ami["us-east-2-amazonlinux2023"]
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.ansible_controller.id]      ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                                 ###aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp2"
    volume_size=var.disk_size
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
    tags={
      Snapshot = "true"
      Environment = var.env
      Name="${var.name}-root-volume"
    }
  }
  iam_instance_profile = "Administrator_Access"    ###aws_iam_instance_profile.ec2_instance_profile.name   ### IAM Role to be attached to EC2
  user_data = file("user_data_ansible.sh")

  lifecycle{
    prevent_destroy=false
    ignore_changes=[ ami ]
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  metadata_options { #Enabling IMDSv2
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  tags={
    Name="Ansible-Controller"
    Environment = var.env
  }

}

resource "aws_eip" "eip_associate_ansible" {
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_ansible" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.ansible_controller.id
  allocation_id = aws_eip.eip_associate_ansible.id
}

########################################################## OSCAP EC2 Instances ###############################################################
# Security Group for OSCAP EC2 Instances
resource "aws_security_group" "oscap_ec2_instance" {
  name        = "oscap-ec2-instance"
  description = "Security Group for OSCAP EC2 Instance"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "OSCAP-EC2-Instance-sg"
  }
}

resource "aws_instance" "oscap_ec2_instance" {
  count         = 2
  ami           = count.index == 0 ? var.provide_ami["us-east-2-rhel9"] : var.provide_ami["us-east-2-amazonlinux2023"]
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.oscap_ec2_instance.id]      ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                                 ###aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp2"
    volume_size=var.disk_size
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
    tags={
      Snapshot = "true"
      Environment = var.env
      Name="${var.name}-root-volume-${count.index + 1}"
    }
  }
  iam_instance_profile = "Administrator_Access"    ###aws_iam_instance_profile.ec2_instance_profile.name   ### IAM Role to be attached to EC2
  user_data = count.index == 0 ? file("user_data_oscap_rhel9.sh") : file("user_data_oscap_amazonlinux2023.sh")

  lifecycle{
    prevent_destroy=false
    ignore_changes=[ ami ]
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  metadata_options { #Enabling IMDSv2
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  tags={
    Name="oscap-instance-${count.index + 1}"
    Environment = var.env
  }

}

resource "aws_eip" "eip_associate_oscap" {
  count  = 2
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_oscap" {  ### I will use this EC2 behind the ALB.
  count         = 2
  instance_id   = aws_instance.oscap_ec2_instance[count.index].id
  allocation_id = aws_eip.eip_associate_oscap[count.index].id
}
