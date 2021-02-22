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
