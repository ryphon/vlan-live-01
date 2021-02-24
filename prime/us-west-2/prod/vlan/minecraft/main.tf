data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
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

data "aws_ami" "base_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

