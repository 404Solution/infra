variable "vpc_id" {
    description = "The subnets IDS"
    type = string
    default = "vpc-0ee46c443a427c1ad"
}

/*variable "subnet_ids" {
    description = "The subnets IDS"
    type = string
    default = "subnet-0f018e0ee155f82e4"
}*/

variable "env" {
  description = "The ENV instance to use"
  type        = string
  default     = "dev"
}
