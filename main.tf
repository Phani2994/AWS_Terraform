provider "aws" {
  region = var.region
}

variable "region" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {
  description = "variable to hold environment"
  type        = string
}

# variable "cidrblocks" {
#   description = "variable to hold cidrblocks and name tags of vpc and subnet"
#   type = list(object({
#     cidrblock = string,
#     name      = string
#   }))
# }

resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}
resource "aws_subnet" "app_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-app_subnet_1"
  }
}

resource "aws_route_table" "app_rtbl" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {
    Name : "${var.env_prefix}-rtbl"
  }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "assoc-rtbll-subnet" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.app_rtbl.id
}

# If we want to use the default main route table of the vpc (but would not be suggested)
# resource "aws_default_route_table" "main-rtbl" {
#   default_route_table_id = aws_vpc.app_vpc.default_route_table_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.app_igw.id
#   }
#   tags = {
#     Name : "${var.env_prefix}-main_rtbl"
#   }
# }
