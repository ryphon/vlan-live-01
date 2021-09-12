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
  game = "gmod"
  game_type = "deathrun"
  game_name = "Deathrun"
  game_type_short = "dr"
  instance_type = "t3.small"
  workshop_collection = "2227527602"
  image = "hackebein/garrysmod"
  default_map = "dr_minecraft"
  tags = {
    Env = "prod"
  }
}
