variable "ami_id" {
  type        = string
  description = "Amazon machine Image Id like ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type        = string
  description = "Defining Instance type like t2.micro or t3.micro"
}

variable "instance_name" {
  type        = string
  description = "Defining instance name"
}

variable "security_group_ids" {
  type = list(string)
}

# variable "git_user" {
#   type = string
# }
#
# variable "git_password" {
#   type = string
# }
#
# variable "aws_access_key" {
#   type = string
# }
#
# variable "aws_secret_key" {
#   type = string
# }

variable "allocate_subnet_id" {
  type = string
}

variable "associate_public_ip_address" {
  type = bool
}

variable "key_pair_name" {
  type = string
}