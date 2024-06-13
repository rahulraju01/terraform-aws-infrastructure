check "validate_modules" {
  assert {
    condition = var.validation_attributes.subnet_assosicated_vpc_id != ""
    error_message = "Associate at least one vpc id for module: ${var.validation_attributes.subnet_name}"
  }

  assert {
    condition = var.validation_attributes.subnet_assosicated_vpc_id != ""  && var.validation_attributes.subnet_assosicated_vpc_id == var.validation_attributes.module_vpc_id
    error_message = "Referenced vpc id must match with present vpc module"
  }
}