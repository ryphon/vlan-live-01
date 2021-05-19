resource "aws_iam_role" "sls" {
  name = "vlan-flask-sls"
  tags = merge(
    {
      "Name" = "vlan-flask-sls"
    },
    var.tags
  )
  assume_role_policy = <<LAMBDA
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
LAMBDA
}

resource "aws_iam_role_policy_attachment" "sls" {
  role = aws_iam_role.sls.name
  policy_arn = aws_iam_policy.sls.arn
}

resource "aws_iam_role_policy_attachment" "sls-logs" {
  role = aws_iam_role.sls.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "sls" {
  name   = "vlan-flask-sls"
  policy = <<LAMBDA
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "autoscaling:SetDesiredCapacity"
        ],
        "Resource": [
          "${data.terraform_remote_state.gmod_dr.outputs.asg_arn}",
          "${data.terraform_remote_state.gmod_ttt.outputs.asg_arn}",
          "${data.terraform_remote_state.gmod_hdn.outputs.asg_arn}",
          "${data.terraform_remote_state.soldat_ctf.outputs.asg_arn}",
          "${data.terraform_remote_state.soldat_rambo.outputs.asg_arn}",
          "${data.terraform_remote_state.soldat_oddball.outputs.asg_arn}",
          "${data.terraform_remote_state.valheim_default.outputs.asg_arn}",
          "${data.terraform_remote_state.minecraft_default.outputs.asg_arn}",
          "${data.terraform_remote_state.minecraft_sf4.outputs.asg_arn}"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
          "autoscaling:DescribeAutoscalingGroups",
          "ec2:DescribeInstances"
        ],
        "Resource": "*"
    },
    {
      "Effect": "Allow",  
      "Action": [
        "kms:*"
      ],
      "Resource": [
        "${aws_kms_key.jwt.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource": [
        "${aws_ssm_parameter.asg.arn}",
        "${aws_ssm_parameter.jwt.arn}"
      ]
    }
  ]
}
LAMBDA
}

