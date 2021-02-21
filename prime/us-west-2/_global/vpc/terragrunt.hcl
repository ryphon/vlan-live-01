# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "."
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  vpc_name = "public"
  vpc_cidr_block = "10.0.0.0/16"
  subnet_count = 3
  subnet_size = 4
  internet = true
  ssh = true
  http = true
  https = true
  ephemeral = true
  tags = {
    Env = "prod"
  }
}
