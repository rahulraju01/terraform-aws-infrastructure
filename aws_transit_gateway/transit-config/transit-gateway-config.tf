resource "aws_ec2_transit_gateway" "tf_transit_gateway" {
  tags = {
    Name = var.transit_gateway_name
  }
  default_route_table_association = var.allow_default_association_creation
  default_route_table_propagation = var.allow_default_propagation_creation
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tf_transit_gateway.id
}