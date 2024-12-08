resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    command = <<EOT
      # Check if the builder exists
      #if ! docker buildx inspect multiarch-builder &>/dev/null; then
      #  echo "Creating new multiarch-builder"
      #  docker buildx create --name multiarch-builder --use
      #  docker buildx inspect multiarch-builder --bootstrap
      #else
      #  echo "Using existing multiarch-builder"
      #  docker buildx use multiarch-builder
      #fi

      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

      # Build and push the multi-architecture image
      #docker buildx build \
      #  --builder multiarch-builder \
      #  --platform linux/amd64 \
      #  --tag ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}:${var.image_tag} \
      #  --push ${var.app_path}
      docker build \
        --tag ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}:${var.image_tag} ${var.app_path}
      docker push ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}:${var.image_tag}
    EOT
  }

  #triggers = {
  #  directory_hash = md5(
  #    join(
  #      "",
  #      [for f in fileset(abspath(var.app_path), "**") : filebase64sha256("${abspath(var.app_path)}/${f}")]
  #    )
  #  )
  #}

  triggers = {
    run_on_timestamp = timestamp()
  }

}
