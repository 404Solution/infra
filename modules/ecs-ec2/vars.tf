variable "env" {
  description = "The ENV instance to use"
  type        = string
  default     = "dev"
}
variable "role" {
  description = "The Role to deploy"
  type        = string
  default = "EC2SSMRole"
}

variable "profile" {
  description = "The Profile to deploy"
  type        = string
  default = "EC2SSMProfile"
}