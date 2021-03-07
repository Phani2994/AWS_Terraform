provider "aws" {
  region = "eu-west-3"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}

# variable "cidrblocks" {
#   description = "variable to hold cidrblocks and name tags of vpc and subnet"
#   type = list(object({
#     cidrblock = string,
#     name      = string
#   }))
# }

# variable "environment" {
#   description = "variable to hold environment"
#   type        = string
# }

resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "dev_subnet-1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}
