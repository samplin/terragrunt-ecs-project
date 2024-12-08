terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb?ref=v9.12.0"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-06828c4265d5537ce"
    vpc_cidr_block = "10.0.0.0/16"
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
  name                = local.env_vars.locals.name
  load_balancer_type  = "application"
  vpc_id              = dependency.vpc.outputs.vpc_id
  subnets             = dependency.vpc.outputs.public_subnets
  enable_deletion_protection = false

  # Security Group Rules
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = dependency.vpc.outputs.vpc_cidr_block
    }
  }

  # Listeners
  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "${local.env_vars.locals.name}"
      }
    }
  }

  # Target Groups
  target_groups = {
    hello-world = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.env_vars.locals.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.env_vars.locals.tags
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
