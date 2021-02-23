variable "aws_region" {
  type = string
}

variable "tfstate_global_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "tags" {
  type = map(string)
}
