terraform {
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "jira" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.3"
  identifier             = "jira"
  instance_class         = "db.t3.micro"
  multi_az               = false
  db_name                = "jira_db"
  username               = "jirauser"
  password               = "jirauser"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.jira_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.jira_subnet_group.id
  publicly_accessible    = false

  tags = {
    Name = "dev-jira-database"
  }
}

resource "aws_security_group" "jira_sg" {
  name        = "dev-jira_sg-db"
  description = "Allow Jira access DB"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_subnet_group" "jira_subnet_group" {
  name       = "jira_subnet_group"
  subnet_ids = ["subnet-06bc80554f02d8614", "subnet-0d62abcf68a067b35", "subnet-00395acff911333e0"]

  tags = {
    Name = "dev-jira_subnet_group"
  }
}
