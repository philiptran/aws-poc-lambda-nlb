variable "super_cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

locals {
  vpc1_cidr    = cidrsubnet(var.super_cidr_block, 8, 3)
  vpc2_cidr    = cidrsubnet(var.super_cidr_block, 8, 2)
  ingressegress_vpc_cidr = cidrsubnet(var.super_cidr_block, 8, 0)
}
