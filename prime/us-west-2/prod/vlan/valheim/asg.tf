resource "aws_autoscaling_group" "game" {
  name = aws_launch_template.game.name
  max_size = 1
  desired_capacity = 0
  min_size = 0
  force_delete = true
  vpc_zone_identifier = [
    data.terraform_remote_state.vpc.outputs.subnet_ids[0],
    data.terraform_remote_state.vpc.outputs.subnet_ids[1],
    data.terraform_remote_state.vpc.outputs.subnet_ids[2]
  ]
  launch_template {
    id      = aws_launch_template.game.id
    version = "$Latest"
  }
  tags = concat(data.null_data_source.tags.*.outputs,
    [
	    {
	      key = "Name"
	      value = "${var.game}-${var.game_type}"
	      propagate_at_launch = "true"
	    }
    ]
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "game" {
  name                   = "${var.game}-${var.game_type}-terminate"
  autoscaling_group_name = aws_autoscaling_group.game.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 3600
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_metadata = <<EOF
{
  "game": ${var.game},
  "gameType": ${var.game_type},
  "asgName": ${aws_autoscaling_group.game.id}
}
EOF
  notification_target_arn = aws_sqs_queue.game.arn
  role_arn                = aws_iam_role.game.arn
}

resource "aws_sqs_queue" "game" {
  name                      = "${var.game}-${var.game_type}-lifecycle"
  max_message_size          = 2048
  message_retention_seconds = 86400
  tags = var.tags
}
