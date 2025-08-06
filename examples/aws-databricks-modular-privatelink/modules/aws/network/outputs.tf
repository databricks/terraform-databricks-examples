output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "privatelink_subnet_ids" {
  value = aws_subnet.privatelink[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat_gateways[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}