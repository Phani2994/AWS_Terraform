provider "aws" {
  region = var.region
}

resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

module "app_subnet" {
  source            = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone        = var.avail_zone
  env_prefix        = var.env_prefix
  vpc_id            = aws_vpc.app_vpc.id
}

module "app_server" {
  source              = "./modules/webserver"
  vpc_id              = aws_vpc.app_vpc.id
  my_ip               = var.my_ip
  env_prefix          = var.env_prefix
  image_name          = var.image_name
  public_key_location = var.public_key_location
  subnet_id           = module.app_subnet.subnet.id
  avail_zone          = var.avail_zone
  instance_type       = var.instance_type
}
