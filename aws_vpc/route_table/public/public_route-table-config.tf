resource "aws_route_table" "tf_public_route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "public_aws_route_table_association" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.tf_public_route_table.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.internet_gateway_name
  }
}

output "route_table_id" {
  value = aws_route_table.tf_public_route_table.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}
