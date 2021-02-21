# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../_global/websites/static-s3"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  dns_zone = "itisamystery.com"
  analytics = true
  analytic_info = "google-site-verification=L6zcvHAlwk_FYNfeazCCpZZ_kKDS0usj9dU3tkl_v-g"
  tags = {
    Env = "prod"
  }
}
