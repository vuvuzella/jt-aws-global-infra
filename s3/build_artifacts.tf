provider "aws" {
  region = "ap-southeast-2"
  profile = "admin-dev"
}

terraform {
  backend "s3" {
    bucket = "global-infrastructure-states"
    key = "global/s3/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "global-infrastructure-locks"
    encrypt = true
    profile = "admin-dev"
  }
}

resource "aws_s3_bucket" "build_artifacts_bucket" {
  bucket = "global-infrastructure-artifacts"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms" // use aws/s3
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
  # comment out when destroying the state bucket
  # force_destroy = true
}

#------------------------------------------------
# Block public access policy for states bucket
#------------------------------------------------
resource "aws_s3_bucket_public_access_block" "artifacts_block_public_access" {
  bucket = aws_s3_bucket.build_artifacts_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
