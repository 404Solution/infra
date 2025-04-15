variable "env" {
  description = "Environment (e.g. dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with the security group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch EC2"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "allowed_cidrs" {
  description = "List of allowed CIDRs for ingress rules"
  type        = list(string)
}

variable "profile" {
  description = "Name of the instance profile"
  type        = string
}

variable "role" {
  description = "Name of the IAM role for EC2"
  type        = string
}
