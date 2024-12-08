#!/bin/bash

sudo systemctl start docker >/dev/null 2>&1
sudo chown ec2-user /var/run/docker.sock
terragrunt run-all apply --terragrunt-non-interactive
