variable "secret_code_commit_user" {
  type    = string
  default = "user"
}

variable "secret_code_commit_password" {
  type    = string
  default = "password"
}

variable "token_aws_access_key" {
  type    = string
  default = "token"
}

variable "token_aws_secret_key" {
  type    = string
  default = "token"
}

variable "personal_profile" {
  type = string
  default = "rahul-raju-personal-profile"
}

variable "dss_old_profile" {
  type = string
  default = "rahul-raju-dss-profile"
}

variable "dss_new_profile" {
  type = string
  default = "DSS"
}

variable "region" {
  type    = string
  default = "us-east-1"
  description = "Repository will be created in specified region"
}
