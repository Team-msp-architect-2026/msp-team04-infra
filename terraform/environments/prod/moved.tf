moved {
  from = module.prod_vpc[0].aws_route.private_app_to_nat[0]
  to   = module.prod_vpc[0].aws_route.private_app_default_to_tgw[0]
}
