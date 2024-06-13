terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
  profile = var.aws_profile
}

variable "aws_profile" {
    type = string
    default = "gergo.vadasz@outlook.com"
}

resource "aws_vpc" "vpc01" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "vpc01"
  }
}

resource "aws_subnet" "public-subnet-01" {
  vpc_id     = aws_vpc.vpc01.id
  cidr_block = "10.2.0.0/24"

  tags = {
    Name = "public-subnet-01"
  }
}

resource "aws_subnet" "private-subnet-01" {
  vpc_id     = aws_vpc.vpc01.id
  cidr_block = "10.2.1.0/24"

  tags = {
    Name = "private-subnet-01"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc01.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "public-rt" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rt" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.vpc01.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

