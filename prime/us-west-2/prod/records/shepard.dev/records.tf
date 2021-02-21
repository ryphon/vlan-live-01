resource aws_route53_record email {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name    = data.terraform_remote_state.route53.outputs.hosted_zone_name
  type    = "MX"
  ttl     = "300"
  records = ["1 ASPMX.L.GOOGLE.COM.",
             "5 ALT1.ASPMX.L.GOOGLE.COM.",
             "5 ALT2.ASPMX.L.GOOGLE.COM.",
             "10 ALT3.ASPMX.L.GOOGLE.COM.",
             "10 ALT4.ASPMX.L.GOOGLE.COM."]
}

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
