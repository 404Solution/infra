variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  # default     = "us-east-1"
}

variable "env" {
  description = "The ENV instance to use"
  type        = string
  # default     = "dev-"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  # default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  # default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  # default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  # default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "igw_name" {
  description = "Name tag for the internet gateway"
  type        = string
  # default     = "main_internet_gateway"
}

variable "eip_name" {
  description = "Name tag for the EIP"
  type        = string
  # default     = "IGW-IP"
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT gateway"
  type        = string
  # default     = "nat_gateway"
}

variable "public_rt_name" {
  description = "Name tag for the public route table"
  type        = string
  # default     = "public_rt"
}

variable "private_rt_name" {
  description = "Name tag for the private route table"
  type        = string
  # default     = "private_rt"
}
