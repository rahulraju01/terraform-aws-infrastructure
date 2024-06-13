variable "validation_attributes" {
  type = object({
    subnet_assosicated_vpc_id = string
    subnet_name = string
    module_vpc_id = any
  })
}

