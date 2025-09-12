#!/bin/bash
set -xe

# Write ECS cluster configuration
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

# Optional: Increase ECS agent logging for troubleshooting
echo "ECS_LOGLEVEL=info" >> /etc/ecs/ecs.config

# Ensure ECS agent starts on boot
systemctl enable --now ecs

# Update all packages to latest
yum update -y

# (Optional) Install SSM agent if not already present
if ! systemctl is-active --quiet amazon-ssm-agent; then
    yum install -y amazon-ssm-agent
    systemctl enable --now amazon-ssm-agent
fi

# Log completion
echo "ECS instance bootstrap complete at $(date)" >> /var/log/user-data.log
