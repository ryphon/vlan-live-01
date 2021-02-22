resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.game}-${var.game_type}-"
  role = aws_iam_role.game.name
}

resource "aws_iam_role" "game" {
  name = "${var.game}-${var.game_type}-role"
  permissions_boundary = data.terraform_remote_state.permissions_boundary.outputs.service_policy_arn
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
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
NODE
}

resource "aws_iam_role_policy_attachment" "nodegroup" {
  role = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}

resource "aws_iam_policy" "app" {
  name   = "${var.game}-${var.game_type}-policy"
  policy = <<NODE
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
              "s3:ListAllMyBuckets",
              "s3:ListBucket",
              "s3:HeadBucket"
          ],
          "Resource": "*"
      },
      {
          "Sid": "VisualEditor1",
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
          ],
          "Resource": [
              "arn:aws:s3:::${var.game}*/*"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
              "arn:aws:route53:::hostedzone/Z3OPAVCB13L0BG"
          ]
      }
  ]
}
NODE
}

