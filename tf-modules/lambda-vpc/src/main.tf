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
  role             = aws_iam_role.iam_assume_role_for_lambda.arn
  filename         = local.full_filename
  runtime          = var.runtime
  source_code_hash = filebase64sha256(local.full_filename)
  layers           = [aws_lambda_layer_version.dependencies.arn]
  vpc_config {
    security_group_ids = var.vpc_config != null ? var.vpc_config.security_group_ids : []
    subnet_ids         = var.vpc_config != null ? var.vpc_config.subnet_ids : []
  }
  depends_on = [
    aws_iam_role_policy_attachment.attach_lambdaVpcPolicies
  ]
}

resource "aws_iam_role" "iam_assume_role_for_lambda" {
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "policies" {
  name_prefix = var.function_name
  path = "/${var.function_name}/"
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "LambdaVPCPolicy",
        Effect: "Allow",
        Action: [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambdaVpcPolicies" {
  role = aws_iam_role.iam_assume_role_for_lambda.name
  policy_arn = aws_iam_policy.policies.arn
}


resource "aws_lambda_layer_version" "dependencies" {
  layer_name          = "${var.function_name}DependenciesLayer"
  filename            = local.full_dependency_path
  source_code_hash    = filebase64sha256(local.full_dependency_path)
  compatible_runtimes = [
    "nodejs16.x"
  ]

}
