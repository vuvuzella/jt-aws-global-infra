output "id" {
  description = "id of the api gateway"
  value = aws_apigatewayv2_api.apigw.id
}

output "api_endpoint" {
  description = "URI of the api in the for of https://{api-id}.execute-api.amazonaws.com"
  value = aws_apigatewayv2_api.apigw.api_endpoint
}

output "execution_arn" {
  description = "ARN prefix to be used in an aws_lambda_permission"
  value = aws_apigatewayv2_api.apigw.execution_arn
}
