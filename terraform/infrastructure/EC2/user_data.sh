#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# Log the completion
echo "ECS instance setup completed at $(date)" >> /var/log/ecs-setup.log
