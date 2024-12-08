terraform {
    source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr?ref=v2.3.1"
}


inputs = {
  repository_name = local.env_vars.locals.name
  create_lifecycle_policy = false
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
