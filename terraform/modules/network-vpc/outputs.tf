output "network_vpc_id" {
  description = "Network VPC ID."
  value       = aws_vpc.this.id
}

output "network_vpc_cidr" {
  description = "Network VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "tgw_subnet_ids" {
  description = "TGW attachment subnet IDs."
  value       = aws_subnet.tgw[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID."
  value       = aws_nat_gateway.this.id
}

output "nat_eip_id" {
  description = "NAT Gateway Elastic IP ID."
  value       = aws_eip.nat.id
}

output "igw_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "tgw_route_table_id" {
  description = "TGW subnet route table ID."
  value       = aws_route_table.tgw.id
}