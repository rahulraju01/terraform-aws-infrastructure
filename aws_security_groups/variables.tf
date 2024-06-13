variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type    = string
  default = "default"
}

variable "ingress_data_list" {
  type = list(object({
    description = string
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
  }))
}