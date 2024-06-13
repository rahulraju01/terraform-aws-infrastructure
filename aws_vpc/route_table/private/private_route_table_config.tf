resource "aws_route_table" "tf_private_route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "tf_private_aws_route_table_association" {
  subnet_id      = var.private_subnet_id
  route_table_id = aws_route_table.tf_private_route_table.id
}

resource "aws_nat_gateway" "tf_nat_gateway_01" {
  allocation_id = aws_eip.tf_elastic_ip_allocation.id
  subnet_id     = var.attach_public_subnet_nat

  tags = {
    Name = var.nat_gateway_name
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # depends_on = [var.internet_gateway_id]
}

resource "aws_eip" "tf_elastic_ip_allocation" {
  domain = "vpc"

  # depends_on = [var.internet_gateway_id]
}

output "private_route_table_id" {
  value = aws_route_table.tf_private_route_table.id
}

output "tf_nat_gateway_id" {
  value = aws_nat_gateway.tf_nat_gateway_01.id
}