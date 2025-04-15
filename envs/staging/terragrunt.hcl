terraform {
  source = "../../modules/network"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "terraformstatetest11"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "staging-terraform-lock-table"
  }
}

inputs = {
  env = "prod"
}

