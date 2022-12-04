resource "aws_security_group" "vpc2_host_sg" {
  name        = "vpc2/sg-host"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = aws_vpc.vpc2.id

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
    Name = "vpc2/sg-host"
  }
}

resource "aws_security_group" "vpc2_endpoint_sg" {
  name        = "vpc2/sg-ssm-ec2-endpoints"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc2.cidr_block]
  }
  tags = {
    Name = "vpc2/sg-ssm-ec2-endpoints"
  }
}

resource "aws_vpc_endpoint" "vpc2_ssm_endpoint" {
  vpc_id            = aws_vpc.vpc2.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.vpc2_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.vpc2_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "vpc2_ssm_messages_endpoint" {
  vpc_id            = aws_vpc.vpc2.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.vpc2_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.vpc2_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "vpc2_ec2_messages_endpoint" {
  vpc_id            = aws_vpc.vpc2.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.vpc2_endpoint_subnet[*].id
  security_group_ids = [
    aws_security_group.vpc2_endpoint_sg.id,
  ]
  private_dns_enabled = true
}

resource "aws_iam_role" "vpc2_instance_role" {
  name               = "vpc2-ssm-instance-profile-role"
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

resource "aws_iam_instance_profile" "vpc2_instance_profile" {
  name = "vpc2-ssm-instance-profile"
  role = aws_iam_role.vpc2_instance_role.name
}


resource "aws_iam_role_policy_attachment" "vpc2_instance_role_policy_attachment" {
  role       = aws_iam_role.vpc2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "vpc2_host" {
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = aws_subnet.vpc2_protected_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.vpc2_instance_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.vpc2_host_sg.id]
  tags = {
    Name = "vpc2/host"
  }
  user_data = file("install-nginx.sh")
}
