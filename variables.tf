variable "region" {}
variable "vpc_cidr_block" {}
variable "avail_zone" {}
variable "my_ip" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {
  description = "variable to hold environment"
  type        = string
}
variable "instance_type" {}
variable "public_key_location" {}
variable "image_name" {}
