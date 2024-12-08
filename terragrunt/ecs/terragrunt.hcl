terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs?ref=v5.12.0"
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

dependency "ecr" {
  config_path = "../ecr"
  skip_outputs = true
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
   security_group_id  = "sg-0829118ecf03ea9e7"
   target_groups      = {
       hello-world= {
           arn                                = "arn:aws:elasticloadbalancing:us-west-2:867702271478:targetgroup/tf-20241206022902777200000002/dbdd3fdf0301a1d6"
           arn_suffix                         = "targetgroup/tf-20241206022902777200000002/dbdd3fdf0301a1d6"
       }

    
    }
  }
}

dependency "docker_build" {
  config_path = "../docker-build"
  mock_outputs = {
    docker_image_url = "nginx:latest"
  }
}

dependency "asg" {
  config_path = "../asg"
  mock_outputs = {
    autoscaling_group_arn = "arn:aws:autoscaling:us-west-2:867702271478:autoScalingGroup:41b8fdd6-48f0-48c2-9577-e428968b0c5e:autoScalingGroupName/hello-world-asg-20241206022910470800000004"
  }
}

inputs = {
  cluster_name = "${local.env_vars.locals.name}-cluster"

  # Use EC2 capacity provider
  capacity_providers = ["EC2"]
  default_capacity_provider_use_fargate = false

  autoscaling_capacity_providers = {
    # On-demand instances
    ex_1 = {
      auto_scaling_group_arn         = dependency.asg.outputs.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 1
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
  }

  cluster_configuration = {

    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.env_vars.locals.name}-cluster"
      }
    }
  }

  services = {
    hello-world= {
      desired_count = 1

      container_definitions = {
        hello-world = {
          cpu       = 50
          memory    = 128
          essential = true
          image     = "${dependency.docker_build.outputs.docker_image_url}"
          port_mappings = [
            {
              name          = "${local.env_vars.locals.name}"
              containerPort = 5000
              protocol      = "tcp"
            }
          ]

          enable_cloudwatch_logging = true
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_name              = "/aws/ecs/apps/${local.env_vars.locals.name}"
          cloudwatch_log_group_retention_in_days = 7
          log_configuration = {
            logDriver = "awslogs"
            #options = {
            #  awslogs-group         = "/aws/ecs/apps/${local.env_vars.locals.name}"
            #  awslogs-region        = "${local.env_vars.locals.region}"
            #  awslogs-stream-prefix = "ecs"
            #}
          }
        }
      }

      load_balancer = {
        service = {
          target_group_arn = dependency.alb.outputs.target_groups["${local.env_vars.locals.name}"].arn
          container_name   = "${local.env_vars.locals.name}"
          container_port   = 5000
        }
      }

      subnet_ids = dependency.vpc.outputs.private_subnets
      create_security_group = true
      #security_group_ids = [dependency.vpc.outputs.default_security_group_id]

      security_group_rules = {
        alb_ingress_5000 = {
          type                     = "ingress"
          from_port                = 5000
          to_port                  = 5000
          protocol                 = "tcp"
          description              = "Allow ALB traffic to Flask service"
          source_security_group_id = dependency.alb.outputs.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      requires_compatibilities = ["EC2"]
      autoscaling_policies = {}
      capacity_provider_strategy = {
      ex_1 = {
          capacity_provider = "ex_1"
          weight            = 100
          base              = 100
         }
      }
    }
  }

  tags = local.env_vars.locals.tags
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_id = run_cmd("--terragrunt-quiet","aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text")
}
