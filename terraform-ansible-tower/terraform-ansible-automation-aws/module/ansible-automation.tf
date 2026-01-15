# Security Group for ALB
resource "aws_security_group" "ansible_automation_alb" {
  name        = "Ansible-Automation-ALB"
  description = "Security Group for Ansible Automation ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }

  ingress {
    protocol   = "tcp"
    cidr_blocks = var.cidr_blocks
    from_port  = 80
    to_port    = 80
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ansible-Automation-ALB-sg"
  }
}

#S3 Bucket to capture ALB access logs
resource "aws_s3_bucket" "s3_bucket_alb" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = var.access_log_bucket_alb

  force_destroy = true

  tags = {
    Environment = var.env
  }
}

#S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3bucket_encryption_alb" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_alb[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

#Apply Bucket Policy to S3 Bucket
resource "aws_s3_bucket_policy" "s3bucket_policy_alb" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_alb[0].id
  policy = <<EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::033677994240:root"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::s3bucketcapturealblogansible/application_loadbalancer_log_folder/AWSLogs/${data.aws_caller_identity.G_Duty.account_id}/*"
        }
      ]
    }
  EOT

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.s3bucket_encryption_alb]
}

#Application Loadbalancer
resource "aws_lb" "test-application-loadbalancer_alb" {
  name               = var.application_loadbalancer_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.ansible_automation_alb.id]           ###var.security_groups
  subnets            = aws_subnet.public_subnet.*.id

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout = var.idle_timeout
  access_logs {
    bucket  = var.access_log_bucket_alb
    prefix  = var.prefix_s3
    enabled = var.enabled
  }

  tags = {
    Environment = var.env
  }

  depends_on = [aws_s3_bucket_policy.s3bucket_policy_alb]
}

#Target Group of Application Loadbalancer
resource "aws_lb_target_group" "target_group_alb" {
  name     = var.target_group_name
  port     = var.instance_port      ##### Don't use protocol when target type is lambda
  protocol = var.instance_protocol  ##### Don't use protocol when target type is lambda
  vpc_id   = aws_vpc.test_vpc.id
  target_type = var.target_type_ansible
  load_balancing_algorithm_type = var.load_balancing_algorithm_type
  health_check {
    enabled = true ## Indicates whether health checks are enabled. Defaults to true.
    path = var.healthcheck_path     ###"/index.html"
    port = "traffic-port"
    protocol = "HTTPS"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
  }
}

##Application Loadbalancer listener for HTTP
resource "aws_lb_listener" "alb_listener_front_end_HTTP_ansible" {
  load_balancer_arn = aws_lb.test-application-loadbalancer_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = var.type[1]
    target_group_arn = aws_lb_target_group.target_group_alb.arn
     redirect {    ### Redirect HTTP to HTTPS
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

##Application Loadbalancer listener for HTTPS
resource "aws_lb_listener" "alb_listener_front_end_HTTPS_ansible" {
  load_balancer_arn = aws_lb.test-application-loadbalancer_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = var.type[0]
    target_group_arn = aws_lb_target_group.target_group_alb.arn
  }
}

## EC2 Instance1 attachment to Target Group
resource "aws_lb_target_group_attachment" "ec2_instance1_attachment_to_tg_ansible" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.target_group_alb.arn
  target_id        = aws_instance.ansible_automation[count.index].id               #var.ec2_instance_id[0]
  port             = var.instance_port
}

## EC2 Instance2 attachment to Target Group
#resource "aws_lb_target_group_attachment" "ec2_instance2_attachment_to_tg" {
#  target_group_arn = aws_lb_target_group.target_group.arn
#  target_id        = var.ec2_instance_id[1]
#  port             = var.instance_port
#}

############################################################### Ansible-Automation #####################################################################
# Security Group for Ansible-Automation
resource "aws_security_group" "ansible_automation" {
  name        = "Ansible-Automation"
  description = "Security Group for Ansible Automation ALB"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.ansible_automation_alb.id]
  }

  ingress {
    from_port   = 27199
    to_port     = 27199
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
    Name = "ansible-automation-sg"
  }
}

resource "aws_instance" "ansible_automation" {
  count         = var.instance_count
  ami           = var.provide_ami
  instance_type = var.instance_type[4]
  monitoring = true
  vpc_security_group_ids = [aws_security_group.ansible_automation.id]
  subnet_id = aws_subnet.public_subnet[0].id
  root_block_device{
    volume_type="gp3"
    volume_size="20"
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
    tags={
      Name = "${var.name}-${count.index + 1}"
      Environment = var.env
      EBS-backed-AMI = "true"
      Snapshot = "true"
    }
  }
  user_data = file("user_data_ansible_core.sh")
  iam_instance_profile = ""    ### "Administrator_Access"  # IAM Role to be attached to EC2
  
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
    Name = "${var.name}-${count.index + 1}"
    Environment = var.env
    EBS-backed-AMI = "true"
    Snapshot = "true"
  }
}

resource "aws_eip" "eip_associate_ansible" {
  count = var.instance_count
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_ansible" {  ### I will use this EC2 behind the ALB.
  count         = var.instance_count
  instance_id   = aws_instance.ansible_automation[count.index].id
  allocation_id = aws_eip.eip_associate_ansible[count.index].id
}
