terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git?ref=v8.0.0"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-06828c4265d5537ce"
    public_subnets = [
      "subnet-0df699935aae582a0",
      "subnet-05acd147771a2388f",
    ]
    private_subnets = [
      "subnet-0ca018d98ab1cc498",
      "subnet-066b0ce16759d2d2f",
    ]
    default_security_group_id = "sg-0bed8d0afd7d08c81"
  }
}

inputs = {
  name                      = "${local.env_vars.locals.name}-asg"
  desired_capacity          = 0
  min_size                  = 0
  max_size                  = 5
  vpc_zone_identifier       = dependency.vpc.outputs.private_subnets
  health_check_type         = "EC2"
  protect_from_scale_in     = true
  wait_for_capacity_timeout = 0

  # Use the correct EC2 AMI ID (hardcoded here, or move to variables if dynamic selection is required)
  # Launch template
  launch_template_name        = "${local.env_vars.locals.name}-asg"
  launch_template_description = "Launch template"
  update_default_version      = true

  image_id          = local.image_id
  instance_type     = "t3.medium"
  ebs_optimized     = true
  enable_monitoring = true
  user_data     = base64encode(local.user_data)

  create_iam_instance_profile = true
  iam_role_name               = "${local.env_vars.locals.name}-asg-role"
  iam_role_description        = "ECS role for ${local.env_vars.locals.name}-asg"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [dependency.vpc.outputs.default_security_group_id]
    }
  ]

  tags = local.env_vars.locals.tags
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Use an appropriate SSM parameter name for ECS Optimized AMI
  image_id = run_cmd(
    "--terragrunt-quiet",
    "aws",
    "ssm",
    "get-parameter",
    "--name",
    "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id",
    "--query",
    "Parameter.Value",
    "--output",
    "text",
    "--region",
    "us-west-2"
  )


  user_data = <<-EOT
    #!/bin/bash
    echo "ECS_CLUSTER=${local.env_vars.locals.name}-cluster" >> /etc/ecs/ecs.config
  EOT 
}

include "root" {
  path = find_in_parent_folders()
}

