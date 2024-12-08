terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.16.0"
}

inputs = {
  name = "${local.env_vars.locals.name}-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-west-2a", "us-west-2b", "us-west-2c"]

  manage_default_security_group = true
  default_security_group_name = "${local.env_vars.locals.name}-default-sg"

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
  }]

  default_security_group_ingress = [{
    description = "Allow all internal TCP and UDP"
    cidr_blocks = "10.0.0.0/16"
  }]

  enable_nat_gateway = true
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
