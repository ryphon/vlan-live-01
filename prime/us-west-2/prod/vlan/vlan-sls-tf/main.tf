data "terraform_remote_state" "gmod_dr" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/gmod-asg/dr/terraform.tfstate"
  }
}

data "terraform_remote_state" "gmod_ttt" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/gmod-asg/ttt/terraform.tfstate"
  }
}

data "terraform_remote_state" "gmod_hdn" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/gmod-asg/hdn/terraform.tfstate"
  }
}

data "terraform_remote_state" "soldat_ctf" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/soldat-asg/ctf/terraform.tfstate"
  }
}

data "terraform_remote_state" "soldat_oddball" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/soldat-asg/oddball/terraform.tfstate"
  }
}

data "terraform_remote_state" "soldat_rambo" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/soldat-asg/rambo/terraform.tfstate"
  }
}

data "terraform_remote_state" "soldat_dm" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/soldat-asg/dm/terraform.tfstate"
  }
}

data "terraform_remote_state" "valheim_default" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/valheim/default/terraform.tfstate"
  }
}

data "terraform_remote_state" "minecraft_default" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/minecraft/default/terraform.tfstate"
  }
}

data "terraform_remote_state" "minecraft_sf4" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.tfstate_global_bucket
    key    = "prime/${var.aws_region}/prod/vlan/minecraft/sf4/terraform.tfstate"
  }
}
