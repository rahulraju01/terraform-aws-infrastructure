# Creating Security Group with default VPC
resource "aws_security_group" "tf_security_group" {
  name        = var.security_group_name
  description = "Creating security group using terraform"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_data_list
    content {
      description = ingress.value.description
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "id" {
  value = aws_security_group.tf_security_group.id
}
