variable "aws_region" {
  type = string
}

variable "tfstate_global_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "dns_zone" {
  type = string
}

variable "game" {
  type = string
}

variable "game_type" {
  type = string
}

variable "game_type_short" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "instance_type" {
  type = string
}

variable "glst" {
  type = string
}

variable "workshop_collection" {
  type = string
}

variable "docker_image" {
  type = string
}
