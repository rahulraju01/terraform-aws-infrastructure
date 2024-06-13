resource "aws_route" "tf_public_route_igw_config" {
  route_table_id         = var.vpc_route_table_id
  destination_cidr_block = var.igw_destination_cidr_block
  gateway_id             = var.vpc_gateway_id
}





