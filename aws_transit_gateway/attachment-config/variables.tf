variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "transit_gateway_attachment_name" {
  type    = string
  default = "transit_gateway_attachment"
}