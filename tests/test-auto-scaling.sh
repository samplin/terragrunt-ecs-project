#!/bin/bash

# Simulate a load test
TARGET_URL=$(aws elbv2 describe-load-balancers \
     --names hello-world \
     --query "LoadBalancers[0].DNSName" \
     --output text \
     --region us-west-2)

echo "Starting load testing http://${TARGET_URL}/"
curl -s http://${TARGET_URL}/
echo

ab -n 900000 -c 100 http://${TARGET_URL}/

echo "Check the AWS CloudWatch metrics to verify auto-scaling behavior."
