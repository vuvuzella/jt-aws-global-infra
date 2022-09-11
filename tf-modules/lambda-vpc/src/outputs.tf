output "arn" {
  description = "ARN identifying the lambda function"
  value = aws_lambda_function.lambda.arn
}

output "invoke_arn" {
  description = "ARN to be used for invoking the lambda function from an API gateway. To be used in aws_api_gateway_integration"
  value = aws_lambda_function.lambda.invoke_arn
}
