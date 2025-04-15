terraform {
  source = "../../modules/vpc"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "envs-terraformstate"
    key            = "dev/dev-vpc-terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # dynamodb_table = "dev-terraform-lock-table"
    use_lockfile = true
  }
}

# Inputs VPC

/* inputs = {
  region                = "us-east-1"
  env                   = "dev"
  cidr_block            = "10.0.0.0/16"
  availability_zones    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  igw_name              = "main_internet_gateway"
  eip_name              = "IGW-IP"
  nat_gateway_name      = "nat_gateway"
  public_rt_name        = "public_rt"
  private_rt_name       = "private_rt"
} */

inputs = {
  env         = "dev"
  vpc_id      = "vpc-0ee46c443a427c1ad"
  subnet_id   = "subnet-06bc80554f02d8614"
  ami         = "ami-01b799c439fd5516a"
  profile     = "jenkins-profile"
  role        = "jenkins-role"
  allowed_cidrs = ["0.0.0.0/0"]
}