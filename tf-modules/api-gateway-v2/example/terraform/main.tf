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
  lambdas = [
    {
      description = "Example Lambda 1 integration"
      uri = module.example_lambda_1.invoke_arn
      integration_method = "post"
    }
  ]
}

module "example_lambda_1" {
  # source = "git::ssh://vuvuzella@github.com/tf-modules/lambda-vpc/src"
  source            = "github.com/vuvuzella/jt-aws-global-infra/tf-modules/lambda-vpc/src"
  function_name     = "example-apigw-lambda-1"
  file_path         = "../artifacts/app.zip"
  handler           = "index.handler"
  aws_account_id    = "536674233911"  // TODO: Retrieve from SSM
  dependency_path   = "../artifacts/dependencies.zip"
}
