module "vpc2_lambda" {
  source = "./modules/lambda"
  vpc_id = local.vpc2_id
  subnet_ids = local.vpc2_protected_subnet_ids
  super_cidr_block = local.super_cidr_block
}
