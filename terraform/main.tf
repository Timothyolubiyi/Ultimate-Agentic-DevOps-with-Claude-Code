# Random suffix for bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for static website hosting
resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.project_name}-${random_id.bucket_suffix.hex}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Block all public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "site_bucket_pab" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "site_bucket_versioning" {
  bucket = aws_s3_bucket.site_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket for access logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.project_name}-logs-${random_id.bucket_suffix.hex}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Block all public access to log bucket
resource "aws_s3_bucket_public_access_block" "log_bucket_pab" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for the log bucket
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption for site bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "site_bucket_sse" {
  bucket = aws_s3_bucket.site_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 access logging for site bucket
resource "aws_s3_bucket_logging" "site_bucket_logging" {
  bucket        = aws_s3_bucket.site_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "s3-access-logs/"

  depends_on = [aws_s3_bucket_public_access_block.log_bucket_pab]
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront security headers policy
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.project_name}-security-headers"

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; font-src 'self' data:"
      override                 = true
    }
  }
}

# S3 Bucket Policy for CloudFront OAC access
resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.site_bucket_pab]
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id                = "s3_origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  # CloudFront access logging
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.log_bucket.bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  # Custom error response: 404 → /index.html with 200 status
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  # 403 → /index.html with 200 status (for SPA-style routing)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_origin"

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id             = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id  = aws_cloudfront_response_headers_policy.security_headers.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Data source for AWS Account ID
data "aws_caller_identity" "current" {}

# Data source for CloudFront Caching Optimized managed policy
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}
