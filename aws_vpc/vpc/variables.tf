variable "vpc_cidr_block" {
  type = string
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "vpc_name" {
  type    = string
  default = "tf_test_vpc"
}
