terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  } 
}

locals {
  full_filename = "${path.module}/${var.file_path}"
  full_dependency_path = "${path.module}/${var.dependency_path}"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  handler          = var.handler
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = local.full_filename
  runtime          = var.runtime
  source_code_hash = filebase64sha256(local.full_filename)
  layers           = [aws_lambda_layer_version.dependencies.arn]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.function_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_layer_version" "dependencies" {
  layer_name          = "${var.function_name}DependenciesLayer"
  filename            = local.full_dependency_path
  source_code_hash    = filebase64sha256(local.full_dependency_path)
  compatible_runtimes = [
    "nodejs16.x"
  ]

}
