#!/bin/bash

echo shutdown instances in ASG
asg_name=$(aws --region us-west-2 autoscaling describe-auto-scaling-groups|jq -r '.AutoScalingGroups[].AutoScalingGroupName')

ec2_instance_ids=$(aws autoscaling describe-auto-scaling-instances \
  --query "AutoScalingInstances[?AutoScalingGroupName=='${asg_name}'].InstanceId" \
  --output text)

aws autoscaling set-instance-protection \
  --auto-scaling-group-name "${asg_name}" \
  --instance-ids ${ec2_instance_ids} \
  --no-protected-from-scale-in

aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $asg_name \
    --min-size 0 \
    --desired-capacity 0 \
    --max-size 0 \
    --region us-west-2

aws ec2 terminate-instances --instance-ids $ec2_instance_ids --region us-west-2

# Drain each container instance
cluster_name=hello-world-cluster
ecs_instance_ids=$(aws ecs list-container-instances --cluster ${cluster_name} --query "containerInstanceArns" --output text)

for instance_id in ${ecs_instance_ids}; do
  echo drain $instance_id
  aws ecs update-container-instances-state \
    --cluster $cluster_name \
    --container-instances ${instance_id} \
    --status DRAINING
done

echo delete images in ecr
aws ecr list-images --repository-name hello-world --query 'imageIds[*]' --output json > images-to-delete.json
aws ecr batch-delete-image --repository-name hello-world --image-ids file://images-to-delete.json
rm -f images-to-delete.json

echo run destroy
terragrunt run-all destroy --terragrunt-non-interactive
