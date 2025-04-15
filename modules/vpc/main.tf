terraform {
  backend "s3" {}
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.env
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true
   
  tags = {
    Environment = var.env
  }
}