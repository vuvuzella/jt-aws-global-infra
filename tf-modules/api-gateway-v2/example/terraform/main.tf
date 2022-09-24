terraform {
  required_version = "1.1.9"
  backend "s3" {
    bucket         = "global-infrastructure-states"
    key            = "tf-modules-examples/api-gateway-v2/terraform.state"
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

module "api-gateway-v2" {
  source = "../../src"
  gw_name = "api-gw-v2-example"
  dependency_path = "../artifacts/dependencies.zip"
  lambdas = {
    example-apigw-lambda-1 = {
      description = "Handler 1"
      file_path = "../artifacts/app.zip"
      handler = "index.handler"
    }
    example-apigw-lambda-2 = {
      description = "Handler 2"
      file_path = "../artifacts/app.zip"
      handler = "index.handler"
    }
  }
}

output "printout" {
  value = module.api-gateway-v2.lambdas_output
}
