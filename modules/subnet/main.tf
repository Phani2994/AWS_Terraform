
resource "aws_subnet" "app_subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name : "${var.env_prefix}-app_subnet_1"
  }
}

resource "aws_route_table" "app_rtbl" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name : "${var.env_prefix}-rtbl"
  }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_route_table_association" "assoc-rtbll-subnet" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.app_rtbl.id
}
