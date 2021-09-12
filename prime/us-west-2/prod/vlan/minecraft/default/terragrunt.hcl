# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "..//."
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  dns_zone = "itisamystery.com"
  game = "minecraft"
  game_type = "default"
  game_name = "Vanilla"
  game_type_short = "def"
  instance_type = "t3.large"
  image = "itzg/minecraft-server"
  tags = {
    Game = "minecraft"
    GameType = "default"
    Env = "prod"
  }
}
