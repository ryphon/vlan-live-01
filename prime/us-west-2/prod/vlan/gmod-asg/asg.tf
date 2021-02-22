resource "aws_autoscaling_group" "app_blue" {
  name = "${aws_launch_template.app.name}-blue"
  max_size = var.blue_maximum_instances
  desired_capacity = var.blue_desired_instances
  min_size = var.blue_desired_instances
  force_delete = true
  target_group_arns = [aws_lb_target_group.jms.arn]
  vpc_zone_identifier = [
    local.subnets[0],
    local.subnets[1]
    # limiting to two AZs for css
  ]
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  tags = concat(data.null_data_source.tags.*.outputs,
    [
	    {
	      key = "Name"
	      value = "${var.tla}-${var.env_name}-worker-blue"
	      propagate_at_launch = "true"
	    },
	    {
	      key = "HighAvail"
	      value = "${var.tla}-${var.env_name}-blue"
	      propagate_at_launch = "true"
	    },
	    {
	      key = "Environment"
	      value = var.env_name
	      propagate_at_launch = true
	    },
	    {
	      key = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
	      value = "owned"
	      propagate_at_launch = "true"
	    }
    ]
  )

  lifecycle {
    create_before_destroy = true
  }
}
