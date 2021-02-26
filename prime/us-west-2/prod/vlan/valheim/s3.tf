resource "aws_s3_bucket" "worlds" {
  bucket = "vlan-${var.game}-${var.game_type}-backup"
  tags = var.tags
}
