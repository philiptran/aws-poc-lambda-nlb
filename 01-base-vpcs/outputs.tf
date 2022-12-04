output "super_cidr_block" {
  value = var.super_cidr_block
}
output "vpc1_host_ip" {
  value = aws_instance.vpc1_host.private_ip
}
output "vpc1_nlb_dns_name" {
  value = aws_lb.vpc1_nlb.dns_name
}
output "vpc2_host_ip" {
  value = aws_instance.vpc2_host.private_ip
}
output "vpc2_id" {
  value = aws_vpc.vpc2.id
}
output "vpc2_protected_subnet_ids" {
  value = aws_subnet.vpc2_protected_subnet[*].id
}
