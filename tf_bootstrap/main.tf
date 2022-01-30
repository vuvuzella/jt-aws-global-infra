provider "aws" {
  profile = "admin-dev"
  region = "ap-southeast-2"
}

#------------------------------------------------
# Remote state for all global infrastructure
#------------------------------------------------
terraform {
  backend "s3" {
    bucket = "global-infrastructure-states"
    key = "global/remote_state/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "global-infrastructure-locks"
    encrypt = true
    profile = "admin-dev"
    kms_key_id = "alias/tfstate-bucket-key"
  }
}

#------------------------------------------------
# Locks dynamodb table for global infrastructure
#------------------------------------------------
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

#------------------------------------------------
# s3 bucket for global infrastructure tfstates
#------------------------------------------------
resource "aws_s3_bucket" "states" {
  bucket = "global-infrastructure-states"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket_key.arn
        sse_algorithm = "aws:kms"
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
resource "aws_s3_bucket_public_access_block" "states_block_public_access" {
  bucket = aws_s3_bucket.states.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#------------------------------------------------
# Locks dynamodb table for admin-dev projects
#------------------------------------------------
resource "aws_dynamodb_table" "projects_locks" {
  name = "admin-dev-projects-locks"
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

#------------------------------------------------
# s3 bucket table for projects tfstates
#------------------------------------------------
resource "aws_s3_bucket" "projects_bucket" {
  bucket = "admin-dev-projects-tfstates"
  acl = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket_key.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
  lifecycle {
    prevent_destroy = false
  }
  # comment out when destroying the state bucket
  # force_destroy = true
}

#------------------------------------------------
# Block public access policy for projects_bucket
#------------------------------------------------
resource "aws_s3_bucket_public_access_block" "projects_bucket_block_public_access" {
  bucket = aws_s3_bucket.projects_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

#------------------------------------------------
# KMS keys to encrypt our buckets
#------------------------------------------------
resource "aws_kms_key" "bucket_key" {
  description = "This key is used to encrypt tfstate s3 buckets"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_alias" "bucket_key_alias" {
  name = "alias/tfstate-bucket-key" 
  target_key_id = aws_kms_key.bucket_key.key_id
}
