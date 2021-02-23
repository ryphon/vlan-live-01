resource "aws_security_group_rule" "gmodtcp" {
  count = var.game == "gmod" ? 1 : 0
  type              = "ingress"
  from_port         = 27015
  to_port           = 27015
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "gmodudp" {
  count = var.game == "gmod" ? 1 : 0
  type              = "ingress"
  from_port         = 27015
  to_port           = 27015
  protocol          = "UDP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "soldattcp2" {
  count = var.game == "soldat" ? 1 : 0
  type              = "ingress"
  from_port         = 23083
  to_port           = 23083
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "soldattcp" {
  count = var.game == "soldat" ? 1 : 0
  type              = "ingress"
  from_port         = 23073
  to_port           = 23073
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "soldatudp" {
  count = var.game == "soldat" ? 1 : 0
  type              = "ingress"
  from_port         = 23073
  to_port           = 23073
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "valheimtcp" {
  count = var.game == "valheim" ? 1 : 0
  type              = "ingress"
  from_port         = 2456
  to_port           = 2458
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "valheimudp" {
  count = var.game == "valheim" ? 1 : 0
  type              = "ingress"
  from_port         = 2456
  to_port           = 2458
  protocol          = "UDP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "minecrafttcp" {
  count = var.game == "minecraft" ? 1 : 0
  type              = "ingress"
  from_port         = 25565
  to_port           = 25565
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "minecrafttcp2" {
  count = var.game == "minecraft" ? 1 : 0
  type              = "ingress"
  from_port         = 9123
  to_port           = 9123
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}

resource "aws_security_group_rule" "web" {
  count = var.game == "minecraft" ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.game.id
}
resource "aws_security_group" "game" {
  name   = "${var.game}-${var.game_type}-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags,
    {
      "Name" = "${var.game}-${var.game_type}-sg"
    }
  )
}
