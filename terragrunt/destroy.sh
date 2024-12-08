#!/bin/bash

echo shutdown instances in ASG
#aws autoscaling update-auto-scaling-group \
#    --auto-scaling-group-name $(aws --region us-west-2 autoscaling describe-auto-scaling-groups|jq -r '.AutoScalingGroups[].AutoScalingGroupName') \
#    --min-size 0 \
#    --desired-capacity 0 \
#    --max-size 0 \
#    --region us-west-2

echo delete images in ecr
aws ecr list-images --repository-name hello-world --query 'imageIds[*]' --output json > images-to-delete.json
aws ecr batch-delete-image --repository-name hello-world --image-ids file://images-to-delete.json
rm -f images-to-delete.json

echo run destroy
terragrunt run-all destroy --terragrunt-non-interactive
