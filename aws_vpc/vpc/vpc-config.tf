resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.instance_tenancy
  tags = {
    Name = var.vpc_name
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_name" {
  value = var.vpc_name
}
