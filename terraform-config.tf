terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.dss_new_profile
}

locals {
  terraform_prefix                    = "tf"
  vpc_name                            = join("-", [local.terraform_prefix, "vpc"])
  instance_name                       = join("-", [local.terraform_prefix, "ec2-instance"])
  security_group_name                 = join("-", [local.terraform_prefix, "sg"])
  subnet_name                         = join("-", [local.terraform_prefix, "subnet"])
  route_table_name                    = join("-", [local.terraform_prefix, "route-table"])
  internet_gateway_name               = join("-", [local.terraform_prefix, "igw"])
  nat_gateway_name                    = join("-", [local.terraform_prefix, "nat"])
  key_pair_name                       = join("-", [local.terraform_prefix, "kp"])
  transit_gateway_name                = join("-", [local.terraform_prefix, "transit-gateway"])
  transit_gateway_route_table_name    = join("-", [local.terraform_prefix, "tgw-route-table"])
  transit_gateway_vpc_attachment_name = join("-", [local.terraform_prefix, "tgw-vpc-attach"])
  default_cidr_block                  = "0.0.0.0/0"
}

#module "create-aws-ec2-instance" {
#  source                      = "./aws_ec2_instance"
#  ami_id                      = "ami-0c7217cdde317cfec"
#  instance_type               = "t2.micro"
#  instance_name               = "tf-test-instance-3"
#  security_group_ids          = [module.create_public_instance_security_group_vpc_01.id]
#  git_user                    = var.secret_code_commit_user
#  git_password                = var.secret_code_commit_password
#  aws_access_key              = var.token_aws_access_key
#  aws_secret_key              = var.token_aws_secret_key
#  key_pair_name               = "tf-test-instance-2-key-pair"
#  allocate_subnet_id          = module.create_public_subnet_vpc_01.subnet_id
#  associate_public_ip_address = true
#}

# --------------- EC2 INSTANCE CREATION ------------------------
module "create_public_aws_ec2_instance_vpc_01" {
  source                      = "./aws_ec2_instance"
  ami_id                      = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  instance_name               = join("-", [local.instance_name, "public-test-01"])
  security_group_ids          = [module.create_public_instance_security_group_vpc_01.id]
  allocate_subnet_id          = module.create_public_subnet_vpc_01.subnet_id
  associate_public_ip_address = true
  key_pair_name               = join("-", [local.key_pair_name, "public-instance-01"])
}

module "create_private_aws_ec2_instance_vpc_02" {
  source                      = "./aws_ec2_instance"
  ami_id                      = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  instance_name               = join("-", [local.instance_name, "private-test-02"])
  security_group_ids          = [module.create_private_instance_security_group_vpc_02.id]
  allocate_subnet_id          = module.create_private_subnet_vpc_02.subnet_id
  associate_public_ip_address = false
  key_pair_name               = join("-", [local.key_pair_name, "private-instance-01"])
}
# -------------------------------------------------------------

# --------------- SECURITY GROUP CREATION ---------------------
module "create_public_instance_security_group_vpc_01" {
  source              = "./aws_security_groups"
  security_group_name = join("-", [local.security_group_name, "public-test-instance-01-vpc-01"])
  vpc_id              = module.create_vpc_01.vpc_id
  ingress_data_list   = [
    {
      cidr_blocks = ["0.0.0.0/0"], description = "Allow SSH from anywhere", from_port = 22, to_port = 22,
      protocol    = "tcp"
    },
    {
      cidr_blocks = ["0.0.0.0/0"], description = "Allow tomcat port 8080 for accessing application", from_port = 8080,
      to_port     = 8080, protocol = "tcp"
    }
  ]
}
#
module "create_private_instance_security_group_vpc_02" {
  source              = "./aws_security_groups"
  security_group_name = join("-", [local.security_group_name, "private-test-instance-02-vpc-02"])
  vpc_id              = module.create_vpc_02.vpc_id
  ingress_data_list   = [
    {
      cidr_blocks = [module.create_public_subnet_vpc_01.subnet_cidr_block],
      description = "Allow SSH from public subnet based instance", from_port = 22, to_port = 22, protocol = "tcp"
    },
    {
      cidr_blocks = [module.create_public_subnet_vpc_01.subnet_cidr_block],
      description = "Allow ping from public subnet based instance", from_port = -1, to_port = -1, protocol = "ICMP"
    }
  ]
}
# -------------------------------------------------------------

# --------------- VPC CREATION --------------------------------
module "create_vpc_01" {
  source         = "./aws_vpc/vpc/"
  vpc_name       = join("-", [local.vpc_name, "test-public-01"])
  vpc_cidr_block = "20.0.0.0/16"
}

module "create_vpc_02" {
  source         = "./aws_vpc/vpc"
  vpc_name       = join("-", [local.vpc_name, "test-private-01"])
  vpc_cidr_block = "30.0.0.0/16"
}
# ----------------------------------------------------------------

# --------------- SUBNET CREATION --------------------------------
module "create_public_subnet_vpc_01" {
  source            = "./aws_vpc/subnet"
  subnet_name       = join("-", [local.subnet_name, "public-vpc-01"])
  subnet_cidr_block = "20.0.1.0/24"
  vpc_id            = module.create_vpc_01.vpc_id
}

module "create_private_subnet_vpc_01" {
  source            = "./aws_vpc/subnet"
  subnet_name       = join("-", [local.subnet_name, "private-vpc-01"])
  subnet_cidr_block = "20.0.2.0/24"
  vpc_id            = module.create_vpc_01.vpc_id
}

module "create_private_subnet_vpc_02" {
  source            = "./aws_vpc/subnet"
  subnet_name       = join("-", [local.subnet_name, "private-vpc-02"])
  subnet_cidr_block = "30.0.3.0/24"
  vpc_id            = module.create_vpc_02.vpc_id
}
# ----------------------------------------------------------------

# --------------- ROUTE TABLE && CONFIG CREATION -----------------
module "create_public_route_table_vpc_01" {
  source                = "./aws_vpc/route_table/public"
  route_table_name      = join("-", ["public-route-table", "vpc-01"])
  public_subnet_id      = module.create_public_subnet_vpc_01.subnet_id
  internet_gateway_name = join("-", [local.internet_gateway_name, "public-route-table", "vpc-01"])
  vpc_id                = module.create_vpc_01.vpc_id
}

module "create_private_route_table_vpc_02" {
  source                   = "./aws_vpc/route_table/private"
  route_table_name         = join("-", [local.route_table_name, "private-vpc-02"])
  private_subnet_id        = module.create_private_subnet_vpc_02.subnet_id
  nat_gateway_name         = join("-", [local.nat_gateway_name, "private-route-table", "vpc-02"])
  vpc_id                   = module.create_vpc_02.vpc_id
  attach_public_subnet_nat = module.create_public_subnet_vpc_01.subnet_id
}

module "create_public_igw_route_config_vpc_01" {
  source                     = "./aws_vpc/route_config/public/igw_route_config"
  igw_destination_cidr_block = local.default_cidr_block
  vpc_gateway_id             = module.create_public_route_table_vpc_01.internet_gateway_id
  vpc_route_table_id         = module.create_public_route_table_vpc_01.route_table_id
}

module "create_public_tgw_route_config_vpc_01" {
  source                     = "./aws_vpc/route_config/public/tgw_route_config"
  tgw_destination_cidr_block = module.create_private_subnet_vpc_02.subnet_cidr_block
  transit_gateway_id         = module.create_transit_gateway.transit_gateway_id
  vpc_route_table_id         = module.create_public_route_table_vpc_01.route_table_id
}

module "create_private_tgw_route_config_vpc_02" {
  source                     = "./aws_vpc/route_config/public/tgw_route_config"
  tgw_destination_cidr_block = module.create_public_subnet_vpc_01.subnet_cidr_block
  transit_gateway_id         = module.create_transit_gateway.transit_gateway_id
  vpc_route_table_id         = module.create_private_route_table_vpc_02.private_route_table_id
}

# ----------------------------------------------------------
# --------------- TRANSIT GATEWAY CREATION -----------------

module "create_transit_gateway" {
  source                             = "./aws_transit_gateway/transit-config"
  transit_gateway_name               = join("-", [local.transit_gateway_name])
  allow_default_association_creation = "disable"
  allow_default_propagation_creation = "disable"
}

module "create_tgw_vpc_attachment_create_vpc_01" {
  source                          = "./aws_transit_gateway/attachment-config"
  transit_gateway_attachment_name = join("-", [
    local.transit_gateway_vpc_attachment_name, module.create_vpc_01.vpc_name
  ])
  subnet_ids         = [module.create_public_subnet_vpc_01.subnet_id]
  vpc_id             = module.create_vpc_01.vpc_id
  transit_gateway_id = module.create_transit_gateway.transit_gateway_id
}

module "create_tgw_vpc_attachment_create_vpc_02" {
  source                          = "./aws_transit_gateway/attachment-config"
  transit_gateway_attachment_name = join("-", [
    local.transit_gateway_vpc_attachment_name, module.create_vpc_02.vpc_name
  ])
  subnet_ids         = [module.create_private_subnet_vpc_02.subnet_id]
  vpc_id             = module.create_vpc_02.vpc_id
  transit_gateway_id = module.create_transit_gateway.transit_gateway_id
}

module "create_tgw_route_table" {
  source                           = "./aws_transit_gateway/route-config"
  transit_gateway_id               = module.create_transit_gateway.transit_gateway_id
  transit_gateway_route_table_name = join("-", [local.transit_gateway_route_table_name])
  depends_on                       = [module.create_tgw_vpc_attachment_create_vpc_01]
}

# association and propagation for vpc-01
module "create_tgw_rt_association_vpc_01" {
  source                            = "./aws_transit_gateway/route_association"
  transit_gateway_route_table_id    = module.create_tgw_route_table.transit_gateway_route_table_id
  transit_gateway_vpc_attachment_id = module.create_tgw_vpc_attachment_create_vpc_01.transit_gateway_vpc_attachment_id
  depends_on                        = [module.create_tgw_vpc_attachment_create_vpc_01, module.create_tgw_route_table]
}

module "create_tgw_rt_propagation_vpc_01" {
  source                            = "./aws_transit_gateway/route_propagation"
  transit_gateway_route_table_id    = module.create_tgw_route_table.transit_gateway_route_table_id
  transit_gateway_vpc_attachment_id = module.create_tgw_vpc_attachment_create_vpc_01.transit_gateway_vpc_attachment_id
  depends_on                        = [module.create_tgw_vpc_attachment_create_vpc_01, module.create_tgw_route_table]
}

# association and propagation for vpc-02
module "create_tgw_rt_association_vpc_02" {
  source                            = "./aws_transit_gateway/route_association"
  transit_gateway_route_table_id    = module.create_tgw_route_table.transit_gateway_route_table_id
  transit_gateway_vpc_attachment_id = module.create_tgw_vpc_attachment_create_vpc_02.transit_gateway_vpc_attachment_id
  depends_on                        = [module.create_tgw_vpc_attachment_create_vpc_02, module.create_tgw_route_table]
}

module "create_tgw_rt_propagation_vpc_02" {
  source                            = "./aws_transit_gateway/route_propagation"
  transit_gateway_route_table_id    = module.create_tgw_route_table.transit_gateway_route_table_id
  transit_gateway_vpc_attachment_id = module.create_tgw_vpc_attachment_create_vpc_02.transit_gateway_vpc_attachment_id
  depends_on                        = [module.create_tgw_vpc_attachment_create_vpc_02, module.create_tgw_route_table]
}
# ----------------------------------------------------------------
# ------------- Module Validation --------------------------------

#data "aws_vpc" "module_vpc_id" {
#  id = module.create_vpc_01.vpc_id
#}

#module "module_validation" {
#  source = "./module_validation"
#  validation_attributes = {
#    subnet_assosicated_vpc_id = module.create_public_subnet_vpc_01.subnet_assosicated_vpc_id
#    subnet_name = module.create_public_subnet_vpc_01.subnet_name
#    module_vpc_id = data.aws_vpc.module_vpc_id
#  }
#}

