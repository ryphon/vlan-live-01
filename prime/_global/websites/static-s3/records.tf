resource aws_route53_record awww {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name = "www.${data.terraform_remote_state.route53.outputs.hosted_zone_name}"
  type = "A"
  alias {
    name = aws_s3_bucket.website_bucket.website_domain
    zone_id = aws_s3_bucket.website_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

resource aws_route53_record a {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name = data.terraform_remote_state.route53.outputs.hosted_zone_name
  type = "A"
  alias {
    name = aws_s3_bucket.website_bucket.website_domain
    zone_id = aws_s3_bucket.website_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

resource aws_route53_record analytics {
  count = var.analytics ? 1 : 0 
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name    = data.terraform_remote_state.route53.outputs.hosted_zone_name
  type    = "TXT"
  ttl     = "300"
  records = [var.analytic_info]
}
