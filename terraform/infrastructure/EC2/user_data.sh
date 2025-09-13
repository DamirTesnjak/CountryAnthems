#!/bin/bash
# Configure ECS agent
# sudo yum update -y
# sudo yum install -y amazon-ecs-init
# sudo systemctl enable ecs
# sudo systemctl start ecs

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# Restart ECS agent to pick up new configuration
#systemctl restart ecs

# Log the completion
echo "ECS instance setup completed at $(date)" >> /var/log/ecs-setup.log
