resource "aws_ec2_transit_gateway_route_table_propagation" "tf_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = var.transit_gateway_vpc_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}