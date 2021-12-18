provider "aws" {
  profile = "admin-dev"
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "global-infrastructure-states"
    key = "global/vpc/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "global-infrastructure-locks"
    encrypt = true
    profile = "admin-dev"
  }
}
