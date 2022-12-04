resource "aws_vpc" "vpc1" {
  cidr_block           = local.vpc1_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc1"
  }
}

resource "aws_subnet" "vpc1_protected_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc1.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.vpc1_cidr, 4, 3 + count.index)

  tags = {
    Name = "vpc1/${data.aws_availability_zones.available.names[count.index]}/protected-subnet"
  }
}

resource "aws_subnet" "vpc1_endpoint_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc1.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.vpc1_cidr, 4, 6 + count.index)

  tags = {
    Name = "vpc1/${data.aws_availability_zones.available.names[count.index]}/endpoint-subnet"
  }
}

resource "aws_subnet" "vpc1_tgw_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc1.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(local.vpc1_cidr, 4, count.index)

  tags = {
    Name = "vpc1/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet"
  }
}


resource "aws_route_table" "vpc1_route_table" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name = "vpc1/route-table"
  }
}

resource "aws_route_table_association" "vpc1_route_table_association" {
  count          = length(aws_subnet.vpc1_protected_subnet[*])
  subnet_id      = aws_subnet.vpc1_protected_subnet[count.index].id
  route_table_id = aws_route_table.vpc1_route_table.id
}
