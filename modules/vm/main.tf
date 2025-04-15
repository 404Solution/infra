terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

resource "aws_iam_instance_profile" "profile" {
  name = var.profile
  role = var.role
}

resource "aws_instance" "main" {
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.profile.name

  tags = {
    Name = var.instance_name
  }


}
