resource "aws_security_group" "vpc1_endpoint_sg" {
  name        = "vpc1/sg-ssm-ec2-endpoints"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc1.cidr_block]
  }
  tags = {
    Name = "vpc1/sg-ssm-ec2-endpoints"
  }
}

resource "aws_security_group" "vpc1_host_sg" {
  name        = "vpc1/sg-host"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc1.cidr_block, aws_vpc.vpc2.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc1/sg-host"
  }
}

resource "aws_vpc_endpoint" "vpc1_ssm_endpoint" {
  vpc_id            = aws_vpc.vpc1.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.vpc1_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.vpc1_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "vpc1_ssm_messages_endpoint" {
  vpc_id            = aws_vpc.vpc1.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.vpc1_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.vpc1_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "vpc1_ec2_messages_endpoint" {
  vpc_id            = aws_vpc.vpc1.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.vpc1_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.vpc1_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_iam_role" "vpc1_instance_role" {
  name               = "vpc1-ssm-instance-profile-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_instance_profile" "vpc1_instance_profile" {
  name = "vpc1-ssm-instance-profile"
  role = aws_iam_role.vpc1_instance_role.name
}


resource "aws_iam_role_policy_attachment" "vpc1_instance_role_policy_attachment" {
  role       = aws_iam_role.vpc1_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "vpc1_host" {
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = aws_subnet.vpc1_protected_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.vpc1_instance_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.vpc1_host_sg.id]
  tags = {
    Name = "vpc1/host"
  }
  user_data = file("install-nginx.sh")
}

# Create an internal NLB to front the EC2 instances in Application VPC
resource "aws_lb" "vpc1_nlb" {
  name               = "vpc1-nlb"
  load_balancer_type = "network"
  subnets            = aws_subnet.vpc1_protected_subnet[*].id
  enable_cross_zone_load_balancing = true
  internal = true
}
resource "aws_lb_listener" "vpc1_nlb_listener" {
  load_balancer_arn = aws_lb.vpc1_nlb.arn
  protocol          = "TCP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpc1_nlb_targetgroup.arn
  }
}

resource "aws_lb_target_group" "vpc1_nlb_targetgroup" {
  name = "vpc1-nlb-tg"
  port = 80
  protocol = "TCP"
  vpc_id = aws_vpc.vpc1.id
  depends_on = [aws_lb.vpc1_nlb]
  lifecycle {
    create_before_destroy = true
  }
  # IP-based target type
  target_type = "ip"

  stickiness {
    enabled = true
    type = "source_ip"
  }
}
resource "aws_lb_target_group_attachment" "vpc1_nlb_tg_targets" {
  target_group_arn  = aws_lb_target_group.vpc1_nlb_targetgroup.arn
  target_id         = aws_instance.vpc1_host.private_ip
  port              = 80
}
