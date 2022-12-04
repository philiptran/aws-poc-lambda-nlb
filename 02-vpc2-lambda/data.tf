data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../01-base-vpcs/terraform.tfstate"
  }
}

data "dns_a_record_set" "vpc1_nlb_ips" {
  host = data.terraform_remote_state.base.outputs.vpc1_nlb_dns_name
}

locals {
  vpc2_id = data.terraform_remote_state.base.outputs.vpc2_id
  vpc2_protected_subnet_ids = data.terraform_remote_state.base.outputs.vpc2_protected_subnet_ids
  super_cidr_block = data.terraform_remote_state.base.outputs.super_cidr_block
}
