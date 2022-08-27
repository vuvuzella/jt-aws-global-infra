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

module "lambda-vpc-example" {
  source         = "../../src"
  function_name  = "example-lambda-vpc"
  file_path      = "../example/artifacts/app.zip" 
  dependency_path = "../example/artifacts/dependencies.zip"
  handler        = "index.handler"
}
