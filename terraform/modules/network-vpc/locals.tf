locals {
  public_subnet_cidrs = var.public_subnet_cidrs != null ? var.public_subnet_cidrs : [
    for index, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, index)
  ]

  tgw_attachment_subnet_cidrs = var.tgw_attachment_subnet_cidrs != null ? var.tgw_attachment_subnet_cidrs : [
    for index, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, index + 10)
  ]
}