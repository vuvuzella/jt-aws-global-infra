provider "aws" {
  profile = "admin-dev"
  region = "ap-southeast-2"
}

resource "aws_dynamodb_table" "locks" {
  name = "global-infrastructure-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "states" {
  bucket = "global-infrastructure-states"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
  # comment out when destroying the state bucket
  # force_destroy = true
}

terraform {
  backend "s3" {
    bucket = "global-infrastructure-states"
    key = "global/remote_state/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "global-infrastructure-locks"
    encrypt = true
    profile = "admin-dev"
  }
}
