variable "env" {
  description = "The ENV instance to use"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
    description = "The subnets IDS"
    type = string
    default = "vpc-0ee46c443a427c1ad"
}