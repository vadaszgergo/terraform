terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc-192-168-1-0_24" {
  cidr_block = "192.168.1.0/24"
  instance_tenancy = "default"
  tags = {
    Name = "vpc-192-168-1-0_24"
  }
}



resource "aws_subnet" "Subnet-2" {
  vpc_id     = aws_vpc.vpc-192-168-1-0_24.id
  cidr_block = "192.168.1.32/27"
  tags = {
    Name = "Subnet-2"
  }
}