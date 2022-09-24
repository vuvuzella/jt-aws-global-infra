// https://ao.ms/how-to-get-the-aws-accountid-in-terraform/
data "aws_caller_identity" "current" {}
