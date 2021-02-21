variable "aws_region" {
	type = string
}

variable "vpc_name" {
	type = string
}

variable "vpc_cidr_block" {
	type = string
	default = "10.0.0.0/8"
}

variable "subnet_count" {
	type = number
	default = 3
}

variable "subnet_size" {
	type = number
	default = 8
	description = "Number of bits to add to the vpc cidr block mask"
}

variable "tags" {
	type = map(string)
}

variable "internet" {
	type = bool
	default = false
	description = "Allow internet access"
}

variable "ssh" {
	type = bool
	default = false
	description = "Allow ssh traffic"
}

variable "http" {
	type = bool
	default = false
	description = "Allow http traffic"
}

variable "https" {
	type = bool
	default = false
	description = "Allow https traffic"
}

variable "minecraft" {
	type = bool
	default = false
	description = "Allow minecraft traffic in"
}

variable "ephemeral" {
	type = bool
	default = false
	description = "Allow ephemeral traffic out"
}
