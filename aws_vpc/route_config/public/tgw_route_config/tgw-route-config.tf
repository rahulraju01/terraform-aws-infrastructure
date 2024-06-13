resource "aws_route" "tf_public_route_igw_config" {
  route_table_id         = var.vpc_route_table_id
  destination_cidr_block = var.tgw_destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}





