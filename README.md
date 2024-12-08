# terragrunt-ecs-project


## Overview

This project creates the following AWS resources:
- **VPC**: A Virtual Private Cloud (VPC) to deploy the resources.
- **ECR**: A private Docker repository to store the Flask application image.
- **ALB**: An Application Load Balancer (ALB) to route traffic to ECS services.
- **ECS**: An Elastic Container Service (ECS) cluster and service to run the Flask application.
- **ASG (Auto Scaling Group)**: To automatically scale EC2 instances running the ECS tasks.
- **CloudWatch**: For logging and monitoring ECS tasks.
- **IAM Roles**: For ECS task execution and EC2 instance roles.

## Prerequisites

- **Terraform**: Install [Terraform](https://www.terraform.io/downloads.html).
- **Terragrunt**: Install [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/).
- **AWS CLI**: Install and configure the [AWS CLI](https://aws.amazon.com/cli/).
- **Docker**: Install [Docker](https://docs.docker.com/get-docker/).

## Setup and Configuration

### 1. Set up AWS Credentials

Ensure that your AWS credentials are set up either by using AWS CLI or environment variables.

```bash
aws configure
```

### 2. Set up

Ensure that your AWS credentials are set up either by using AWS CLI or environment variables.

```bash
cd terragrunt
./setup.sh
```

## destroy

Ensure that your AWS credentials are set up either by using AWS CLI or environment variables.

```bash
cd terragrunt
./destroy.sh
```
