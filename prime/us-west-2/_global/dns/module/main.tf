resource "aws_route53_zone" "main" {
  name = var.dns_zone_name
  tags = merge({Name = var.dns_zone_name }, var.tags)
}
