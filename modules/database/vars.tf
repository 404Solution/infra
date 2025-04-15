variable "aws_region" {
  description = "The AWS region to deploy in"
  default     = "us-east-1"
}
variable "vpc_id" {
  description = "The VPC id"
  default = "vpc-0ee46c443a427c1ad"
}

variable "db_name" {
  description = "The name of the database"
  default     = "jira_db"
}

variable "db_username" {
  description = "The database admin username"
  default     = "jira_db"
}

variable "db_password" {
  description = "The database admin password"
  default     = "jira_db"
}
