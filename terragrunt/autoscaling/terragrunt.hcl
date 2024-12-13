terraform {
  source = "git::https://github.com/cn-terraform/terraform-aws-ecs-service-autoscaling.git?ref=1.0.10"
}

dependency "ecs" {
  config_path = "../ecs"
  mock_outputs = {
    cluster_name = "hello-world-cluster"
  }
}

inputs = {
  ecs_cluster_name     = dependency.ecs.outputs.cluster_name
  ecs_service_name     = "${local.env_vars.locals.name}"
  ecs_service_namespace = "ecs"

  name_prefix          = "${local.env_vars.locals.name}"
  scale_target_max_capacity = 5
  scale_target_min_capacity = 1
  max_cpu_threshold    = 50
  min_cpu_threshold    = 20

  tags = local.env_vars.locals.tags
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
