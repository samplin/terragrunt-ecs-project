variable "aws_region" {
  description = "AWS region for ECR and Docker operations"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "image_name" {
  description = "Docker image name"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "app_path" {
  description = "Path to the application directory"
  type        = string
}
