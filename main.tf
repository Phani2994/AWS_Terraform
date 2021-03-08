provider "aws" {
  region = var.region
}

variable "region" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "my_ip" {}
variable "env_prefix" {
  description = "variable to hold environment"
  type        = string
}
variable "instance_type" {}
variable "public_key_location" {}

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

resource "aws_security_group" "app-sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name : "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# output "aws_ami_id" {
#   value = data.aws_ami.latest-amazon-linux-image
# }

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "key_pair_2"
  public_key = file(var.public_key_location)
}
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.app_subnet_1.id
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  user_data = file("user_data_code.sh")

  tags = {
    Name : "${var.env_prefix}-sever"
  }
}
