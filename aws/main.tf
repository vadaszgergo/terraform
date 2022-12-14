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

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "vpc1"
  }
}



resource "aws_subnet" "vpc1-subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.101.0/24"
  tags = {
    Name = "vpc1-subnet1"
  }
}

resource "aws_subnet" "vpc1-subnet2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.200.0/24"
  tags = {
    Name = "vpc1-subnet2"
  }
}
