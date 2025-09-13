locals {
  selected_subnet_keys_ecs-agent = ["private-ecs-agent-2a", "private-ecs-agent-2b", "private-ecs-agent-2c"]
  selected_subnet_keys_ecs-telemetry = ["private-ecs-telemetry-2a", "private-ecs-telemetry-2b", "private-ecs-telemetry-2c"]
  selected_subnet_keys_ecs = ["private-ecs-2a", "private-ecs-2b", "private-ecs-2c"]
  selected_subnet_keys_ecr-dkr = ["private-ecr-dkr-2a", "private-ecr-dkr-2b", "private-ecr-dkr-2c"]
  selected_subnet_keys_ecr-api = ["private-ecr-api-2a", "private-ecr-api-2b", "private-ecr-api-2c"]
  selected_subnet_keys_ssm = ["private-ssm-2a", "private-ssm-2b", "private-ssm-2c"]
  selected_subnet_keys_ec2messages = ["private-ec2messages-2a", "private-ec2messages-2b", "private-ec2messages-2c"]
  selected_subnet_keys_ssmmessages = ["private-ssmmessages-2a", "private-ssmmessages-2b", "private-ssmmessages-2c"]


  ecs-agent_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ecs-agent : aws_subnet.private[k].id
  ]

  ecs-telemetry_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ecs-telemetry : aws_subnet.private[k].id
  ]

  ecs_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ecs : aws_subnet.private[k].id
  ]

  ecr-dkr_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ecr-dkr : aws_subnet.private[k].id
  ]

  ecr-api_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ecr-api : aws_subnet.private[k].id
  ]

  ssm_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ssm : aws_subnet.private[k].id
  ]

  ec2messages_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ec2messages : aws_subnet.private[k].id
  ]

  ssmmessages_selected_subnet_ids = [
    for k in local.selected_subnet_keys_ssmmessages : aws_subnet.private[k].id
  ]
}