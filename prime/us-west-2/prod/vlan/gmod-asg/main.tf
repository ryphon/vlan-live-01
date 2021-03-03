resource "aws_key_pair" "key" {
  key_name   = "${var.game}-${var.game_type}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDGD3uPs2XowC99ziLChGbtEopeXrimsbk/3HgLf44Misl/37PxrYOA94CZzb6cC+Ih3bqtW6ZcuqOk2/FoQNdSYv7R3IiqoHyELcmNDkcMBXg1QjjOot75KM52OHxcx2SzF/7dzF05Ohq+DYyenUDv+hECSkWFPqM2Ko2Yq2R3RHaIMNaXpaUuaa55FxqoJbQNTl9/rVzsRYAoRieW3Hp5C+5BIs2WirWTPyJYSmKjrWZdFljsecEzjqhFUTd0wVWpKJaP+3saQRkJ3z5Iyy4liOnkkpDwMgf/FH0HOLh3z/ylpAKAstrCNA9dByi8pJguVsBtDjUTPDle13U6xyn"
}

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

data "terraform_remote_state" "vlan-sls" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/vlan-sls-tf/terraform.tfstate"
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

