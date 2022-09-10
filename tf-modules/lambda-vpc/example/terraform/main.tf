terraform {
  required_version = "1.1.9"
  backend "s3" {
    bucket         = "global-infrastructure-states"
    key            = "tf-modules-examples/lambda-vpc/terraform.state"
    region         = "ap-southeast-2"
    dynamodb_table = "global-infrastructure-locks"
    encrypt        = true
    profile        = "admin-dev"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  } 
}

provider "aws" {
  profile = "admin-dev"
  region  = "ap-southeast-2"
}

locals {
  vpc_id = "vpc-089db66b70fffa9df"
}

data "aws_subnets" "subnet" {
  filter {
    name = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_security_groups" "sg" {
  filter {
    name = "vpc-id"
    values = [local.vpc_id]
  }
}

module "lambda-vpc-example" {
  source          = "../../src"
  function_name   = "example-lambda-vpc"
  file_path       = "../artifacts/app.zip"
  handler         = "index.handler"
  aws_account_id  = "536674233911"  // TODO: Retrieve from SSM
  dependency_path = "../artifacts/dependencies.zip"
  # Filling in vpc_config will make the lambda connect to a vpc
  # vpc_config      = {
  #   subnet_ids = data.aws_subnets.subnet.ids
  #   security_group_ids = data.aws_security_groups.sg.ids
  # }
}
