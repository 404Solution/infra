terraform {
  backend "s3" {}
}

resource "aws_efs_file_system" "this" {
  creation_token   = "main-efs"
  performance_mode = "generalPurpose"
  encrypted        = true

  tags = {
    Name = "${var.env}-efs"
  }
}

resource "aws_efs_mount_target" "private_a" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = "subnet-06bc80554f02d8614"
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "private_b" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = "subnet-0d62abcf68a067b35"
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "private_c" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = "subnet-00395acff911333e0"
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.env}-efs-sg"
  description = "Allow NFS traffic to EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-efs-sg"
  }
}