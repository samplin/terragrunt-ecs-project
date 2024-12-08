terraform {
  source = "../modules/docker-build"
}

inputs = {
  aws_region  = local.env_vars.locals.region
  account_id  = local.env_vars.locals.account_id
  image_name  = local.env_vars.locals.name
  app_path    = local.env_vars.locals.app_path
  image_tag   = "latest"
  #image_tag   = local.env_vars.locals.timestamp
}

locals {
  timestamp = run_cmd("--terragrunt-quiet", "date", "+%s")
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include "root" {
  path = find_in_parent_folders()
}
