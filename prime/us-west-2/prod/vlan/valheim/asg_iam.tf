resource "aws_iam_instance_profile" "game" {
  name_prefix = "${var.game}-${var.game_type}-"
  role = aws_iam_role.game.name
}

resource "aws_iam_role" "game" {
  name = "${var.game}-${var.game_type}-role"
  tags = merge(
    {
      "Name" = "${var.game}-${var.game_type}"
    },
    var.tags
  )
  assume_role_policy = <<NODE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "autoscaling.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
NODE
}

resource "aws_iam_role_policy_attachment" "game" {
  role = aws_iam_role.game.name
  policy_arn = aws_iam_policy.game.arn
}

resource "aws_iam_policy" "game" {
  name   = "${var.game}-${var.game_type}-policy"
  policy = <<NODE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:CompleteLifecycleAction"
      ],
      "Resource": "${aws_autoscaling_group.game.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:HeadBucket"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.game.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::vlan-${var.game}-${var.game_type}-backup",
        "arn:aws:s3:::vlan-${var.game}-${var.game_type}-backup/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
          "arn:aws:route53:::hostedzone/${data.terraform_remote_state.route53.outputs.hosted_zone_id}"
      ]
    }
  ]
}
NODE
}

