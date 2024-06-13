resource "aws_ec2_transit_gateway_route_table" "transit_gateway_route_table" {
  transit_gateway_id = var.transit_gateway_id
  tags               = {
    Name = var.transit_gateway_route_table_name
  }
}

output "transit_gateway_route_table_id" {
  value = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}