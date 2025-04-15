terraform {
  backend "s3" {}
}

resource "aws_security_group" "jira" {
  name        = "${var.env}-jira-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = "vpc-0ee46c443a427c1ad"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_iam_instance_profile" "profile" {
  name = var.profile
  role = var.role
}

resource "aws_key_pair" "deployer" {
  key_name   = "Jorge"
  public_key = file("C:/Users/Andres/.ssh/mykey.pub") 
}

resource "aws_instance" "jira" {
  ami                  = "ami-04a81a99f5ec58529"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.jira.id]
  subnet_id            = "subnet-06bc80554f02d8614"
  key_name      = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.profile.name
  //user_data = "${file("install.sh")}"

  tags = {
    Name = "${var.env}-jira"
  }
}