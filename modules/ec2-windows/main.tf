terraform {
  backend "s3" {}
}

resource "aws_security_group" "windows" {
  name        = "${var.env}-windows-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = "vpc-040f341de1775ceb1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
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

resource "aws_instance" "windows" {
  ami                  = "ami-07d9456e59793a7d5"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.windows.id]
  subnet_id            = "subnet-0201f29a7841e3478"
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.profile.name
  #user_data            = file("install.sh")

  tags = {
    Name = "${var.env}-windows"
  }
}
