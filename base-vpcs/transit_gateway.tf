resource "aws_ec2_transit_gateway" "tgw" {
  tags = {
    Name = "transit-gateway"
  }
}

# Route table for spoke VPCs
resource "aws_ec2_transit_gateway_route_table" "spoke_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "spoke-route-table"
  }
}

# TGW attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_tgw_attachment" {
  subnet_ids                                      = aws_subnet.vpc1_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.vpc1.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name = "vpc1-attachment"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_tgw_attachment" {
  subnet_ids                                      = aws_subnet.vpc2_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.vpc2.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name = "vpc2-attachment"
  }
}

# TGW route table associations
resource "aws_ec2_transit_gateway_route_table_association" "vpc1_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_association" "vpc2_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}

# Route propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_route_table_propagate_vpc1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_route_table_propagate_vpc2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
}

# Ingress/Egress Routing
resource "aws_ec2_transit_gateway_route_table" "ingressegress_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "ingressegress-route-table"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "ingressegress_vpc_tgw_attachment" {
  subnet_ids                                      = aws_subnet.ingressegress_vpc_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.ingressegress_vpc.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name = "ingressegress-vpc-attachment"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "ingressegress_vpc_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ingressegress_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingressegress_route_table.id
}
# Route propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "ingressegress_route_table_propagate_vpc1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingressegress_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "ingressegress_route_table_propagate_vpc2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ingressegress_route_table.id
}

resource "aws_ec2_transit_gateway_route" "spoke_route_table_default_route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ingressegress_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
  destination_cidr_block         = "0.0.0.0/0"
}
