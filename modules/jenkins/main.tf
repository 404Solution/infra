terraform {
  backend "s3" {}
}

##########################
# Key pair
##########################

resource "aws_key_pair" "deployer" {
  key_name   = "Jorge"
  public_key = file("/Users/cupertino/.ssh/id_ed25519.pub")
}

##########################
# IAM instance profile
##########################

resource "aws_iam_instance_profile" "profile" {
  name = var.profile
  role = var.role
}

##########################
# Security Group Module
##########################

module "jenkins_security_group" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "${var.env}-jenkins-sg"
  description = "Allow HTTP, HTTPS, SSH, and Jenkins traffic"
  vpc_id      = var.vpc_id

  ingress_rules       = ["ssh", "http-80-tcp", "https-443-tcp"]
  ingress_with_cidr_blocks = [
    for cidr in var.allowed_cidrs : {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = cidr
    }
  ]

  egress_rules = ["all-all"]
  tags = {
    Name = "${var.env}-jenkins-sg"
  }
}

##########################
# EC2 Module
##########################

module "jenkins_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"


  name           = "${var.env}-jenkins"
  ami            = var.ami
  instance_type  = "t2.micro"
  subnet_id      = var.subnet_id
  key_name       = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [module.jenkins_security_group.security_group_id]
  iam_instance_profile    = aws_iam_instance_profile.profile.name
  user_data               = file("install.sh")

  tags = {
    Name = "${var.env}-jenkins"
    Environment = var.env
  }
}
