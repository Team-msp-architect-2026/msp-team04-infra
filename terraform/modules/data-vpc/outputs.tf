output "vpc_id" {
  description = "Data VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "Data VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "private_db_subnet_ids" {
  description = "Private DB Subnet IDs."
  value       = aws_subnet.private_db[*].id
}

output "private_cache_subnet_ids" {
  description = "Private Cache Subnet IDs."
  value       = aws_subnet.private_cache[*].id
}

output "private_search_subnet_ids" {
  description = "Private Search Subnet IDs."
  value       = aws_subnet.private_search[*].id
}

output "tgw_attachment_subnet_ids" {
  description = "TGW Attachment Subnet IDs."
  value       = aws_subnet.tgw_attachment[*].id
}

output "private_route_table_id" {
  description = "Data VPC Private Route Table ID."
  value       = aws_route_table.private.id
}

output "tgw_attachment_id" {
  description = "Data VPC TGW Attachment ID."
  value       = try(aws_ec2_transit_gateway_vpc_attachment.this[0].id, null)
}
