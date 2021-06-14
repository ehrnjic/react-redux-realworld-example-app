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
   it is possible to use the list if we need to create
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

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.production-bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.production-bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.production-bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

    restrictions {
        geo_restriction {
          restriction_type = "whitelist"
          locations        = ["BA", "RS", "HR", "US", "CA", "GB", "DE"]
        }
      }

    viewer_certificate {
      cloudfront_default_certificate = true
    }
}
