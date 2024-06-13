resource "aws_subnet" "subnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr_block
  
  tags = {
    Name = var.subnet_name
  }
}

output "subnet_id" {
  value = aws_subnet.subnet.id
#  precondition {
#    condition     = aws_subnet.subnet.vpc_id != ""
#    error_message = "Associate at least one vpc id for module: ${var.subnet_name}"
#  }
#  precondition {
#    condition     = aws_subnet.subnet.vpc_id != var.vpc_id
#    error_message = "Referenced vpc id must match with defined vpc module: ${var.subnet_name}"
#  }
}

output "subnet_cidr_block" {
  value = var.subnet_cidr_block
}

output "subnet_assosicated_vpc_id" {
  value = var.vpc_id
}

output "subnet_name" {
  value = var.subnet_name
}