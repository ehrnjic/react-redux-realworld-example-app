
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

/* 
   it is possible to use the type list if we need to create
   a larger number of s3buckets without repeating the code
*/

resource "aws_s3_bucket" "staging-bucket" {
    bucket = "devopstask-app-staging"
    acl    = "public-read"
    policy = file("pub-staging.json")

    website {
        index_document = "index.html"
    }
}

resource "aws_s3_bucket" "production-bucket" {
    bucket = "devopstask-app-production"
    acl    = "public-read"
    policy = file("pub-production.json")

    website {
        index_document = "index.html"
    }
}

resource "aws_s3_bucket" "archive-bucket" {
  bucket = "devopstask-app-archive"
}

resource "aws_s3_bucket_public_access_block" "acl" {
  bucket = aws_s3_bucket.archive-bucket.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}