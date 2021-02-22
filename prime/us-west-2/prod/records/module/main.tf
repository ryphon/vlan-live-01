data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = "vlan-terragrunt-state"
    key    = "prime/${var.aws_region}/_global/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/_global/dns/${var.dns_zone}/terraform.tfstate"
  }
}
