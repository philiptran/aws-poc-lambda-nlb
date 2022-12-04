output "vpc1_host_ip" {
  value = aws_instance.vpc1_host.private_ip
}

output "vpc2_host_ip" {
  value = aws_instance.vpc2_host.private_ip
}

output "vpc1_nlb_dns_name" {
  value = aws_lb.vpc1_nlb.dns_name
}
