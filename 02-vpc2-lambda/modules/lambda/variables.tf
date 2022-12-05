variable "super_cidr_block" {
  default = "Super CIDR block for all VPCs"
  type    = string
}

variable "vpc_id" {
  description = "VPC id of the integration vpc"
  type = string
}

variable "subnet_ids" {
  description = "Subnet ids of the integration tier"
  type = list  
}

variable "target_url" {
  description = "Target url to pass to lambda's envrionment variable"
  type = string
}

data "aws_region" "current" {}