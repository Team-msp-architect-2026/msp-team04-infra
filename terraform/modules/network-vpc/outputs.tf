output "network_vpc_id" {
  description = "Network VPC ID."
  value       = aws_vpc.this.id
}

output "network_vpc_cidr_block" {
  description = "Network VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Network VPC Public Subnet IDs."
  value       = aws_subnet.public[*].id
}

output "tgw_attachment_subnet_ids" {
  description = "Network VPC TGW Attachment Subnet IDs."
  value       = aws_subnet.tgw_attachment[*].id
}

output "internet_gateway_id" {
  description = "Network VPC Internet Gateway ID."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "Centralized NAT Gateway ID."
  value       = try(aws_nat_gateway.central[0].id, null)
}

output "nat_gateway_public_ip" {
  description = "Centralized NAT Gateway Public IP."
  value       = try(aws_eip.nat[0].public_ip, null)
}

output "public_route_table_id" {
  description = "Public Route Table ID."
  value       = aws_route_table.public.id
}

output "tgw_attachment_route_table_id" {
  description = "TGW Attachment Subnet Route Table ID."
  value       = aws_route_table.tgw_attachment.id
}