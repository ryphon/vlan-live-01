resource "aws_s3_bucket" "worlds" {
  bucket = "vlan-${var.game}-${var.game_type}-backup"
  tags = var.tags

  lifecycle_rule {
    id      = "archive"
    enabled = true

    prefix = "${var.game_type}/archive/"

    tags = var.tags

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 360
    }
  }
}
