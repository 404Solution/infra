variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}
variable "role" {
  description = "The Role to deploy"
  type        = string
}

variable "profile" {
  description = "The Profile to deploy"
  type        = string
}

variable "ami" {
  description = "The type of AMI instance to use"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to use"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "instance_name" {
  description = "The Name of the instance"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}
