output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "env" {
  description = "The environment name"
  value       = var.env
}

output "cidr_block" {
  description = "The CIDR block for the VPC"
  value       = var.cidr_block
}