resource "aws_ec2_transit_gateway_vpc_attachment" "tf_transit_gateway_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id

  tags = {
    Name = var.transit_gateway_attachment_name
  }
}

output "transit_gateway_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tf_transit_gateway_attachment.id
}