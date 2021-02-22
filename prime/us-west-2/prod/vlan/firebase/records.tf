resource aws_route53_record a {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name    = "vlan.${data.terraform_remote_state.route53.outputs.hosted_zone_name}"
  type    = "A"
  ttl     = "300"
  records = ["151.101.1.195", "151.101.65.195"]
}

resource aws_route53_record txt {
  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id
  name    = data.terraform_remote_state.route53.outputs.hosted_zone_name
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=L6zcvHAlwk_FYNfeazCCpZZ_kKDS0usj9dU3tkl_v-g"]
}
