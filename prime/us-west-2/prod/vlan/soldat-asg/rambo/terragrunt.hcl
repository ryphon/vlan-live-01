# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  dns_zone = "itisamystery.com"
  game = "soldat"
  game_type = "rambo"
  game_type_short = "rambo"
  instance_type = "t3.small"
  image = "ryphon/soldat-rambo"
  tags = {
    Game = "soldat"
    GameType = "rambo"
    Env = "prod"
  }
}
