output "vpc_id" {
  description = "App VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Private App Subnet IDs"
  value       = aws_subnet.private_app[*].id
}

output "tgw_attachment_subnet_ids" {
  description = "TGW Attachment Subnet IDs"
  value       = aws_subnet.tgw_attachment[*].id
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public.id
}

output "private_app_route_table_id" {
  description = "Private App Route Table ID"
  value       = aws_route_table.private_app.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "tgw_attachment_id" {
  description = "TGW Attachment ID"
  value       = try(aws_ec2_transit_gateway_vpc_attachment.this[0].id, null)
}