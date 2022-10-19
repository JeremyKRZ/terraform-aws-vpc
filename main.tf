### Module Main

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc-name
    Environment = var.env
    Owner = var.owner
  }
}

