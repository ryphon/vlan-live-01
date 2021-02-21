# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt

  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "primary-account-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

inputs = merge(
  # Configure Terragrunt to use common vars encoded as yaml to help you keep often-repeated variables (e.g., account ID)
  # DRY. We use yamldecode to merge the maps into the inputs, as opposed to using varfiles due to a restriction in
  # Terraform >=0.12 that all vars must be defined as variable blocks in modules. Terragrunt inputs are not affected by
  # this restriction.
  yamldecode(
    file("${get_terragrunt_dir()}/${find_in_parent_folders("region.yaml", "${path_relative_from_include()}/empty.yaml")}"),
  ),
  yamldecode(
    file("${get_terragrunt_dir()}/${find_in_parent_folders("env.yaml", "${path_relative_from_include()}/empty.yaml")}"),
  ),
  # Additional global inputs to pass to all modules called in this directory tree.
  {
    # These variables apply to this entire AWS account. They use to be automatically pulled in using the extra_arguments
    # setting in the root terraform.tfvars file's Terragrunt configuration, but now are hardcoded here.
    aws_account_id                    = "456410706824"
    aws_account_alias                 = "prime"

    terraform_state_s3_bucket         = "primary-account-state"
    terraform_state_aws_region        = "us-west-2"
  },
)
