#!/bin/bash

# Update the system
yum update -y

# Install additional packages if needed
yum install -y awscli
sudo yum update -y
sudo yum install -y ecs-init

# Configure ECS agent
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config

# Start and enable ECS agent
systemctl enable ecs
systemctl start ecs

# Install Session Manager agent for easier access
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure CloudWatch agent (optional)
# yum install -y amazon-cloudwatch-agent

# Log the completion
echo "ECS instance setup completed" >> /var/log/ecs-setup.log
