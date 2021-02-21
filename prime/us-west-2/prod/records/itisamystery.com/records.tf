resource aws_route53_record ns {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name    = data.terraform_remote_state.route53.outputs.hosted_zone_name
  type    = "NS"
  ttl     = "172800"
  records = data.terraform_remote_state.route53.outputs.nameservers
}

resource aws_route53_record soa {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name    = data.terraform_remote_state.route53.outputs.hosted_zone_name
  type    = "SOA"
  ttl     = "900"
  records = [var.soa]
}
