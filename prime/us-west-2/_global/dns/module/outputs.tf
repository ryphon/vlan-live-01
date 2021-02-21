output "hosted_zone_id" {
  value = aws_route53_zone.main.id
}

output "hosted_zone_name" {
  value = aws_route53_zone.main.name
}

output "hosted_zone_domain" {
  value = var.dns_zone_name
}