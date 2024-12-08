output "docker_image_url" {
  value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}:${var.image_tag}"
}
