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

resource "aws_apigatewayv2_integration" "lambda_integrations" {
  count = length(var.lambdas)
  api_id = aws_apigatewayv2_api.apigw.id
  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description = var.lambdas[count.index].description
  integration_method = upper(var.lambdas[count.index].integration_method)
  integration_uri = var.lambdas[count.index].uri
  passthrough_behavior = "WHEN_NO_MATCH"
}
