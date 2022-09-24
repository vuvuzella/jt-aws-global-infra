terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source = "hashicorp/aws",
      version = "4.27.0"
    }
  }
}

locals {

}

resource "aws_apigatewayv2_api" "apigw" {
  name = var.gw_name
  protocol_type = "HTTP"
  description = "HTTP api gateway for ${var.gw_name}"
  tags = {
    Name = var.gw_name
  }
}

module "lambdas" {
  source = "github.com/vuvuzella/jt-aws-global-infra/tf-modules/lambda-vpc/src"

  for_each = var.lambdas
  function_name   = each.key
  file_path       = each.value.file_path
  handler         = each.value.handler
  aws_account_id  = data.aws_caller_identity.current.account_id
  dependency_path = var.dependency_path
}

resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = var.lambdas
  api_id               = aws_apigatewayv2_api.apigw.id
  integration_type     = "AWS_PROXY"
  connection_type      = "INTERNET"
  description          = each.value.description
  integration_method   = "POST"
  integration_uri      = module.lambdas[each.key].invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}
