terraform {
  source = "../../modules/network"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "terraformstatetest11"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "prod-terraform-lock-table"
  }
}

inputs = {
  env = "prod"
}

