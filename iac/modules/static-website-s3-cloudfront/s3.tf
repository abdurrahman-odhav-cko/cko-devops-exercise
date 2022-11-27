resource "aws_s3_bucket" "static_website" {
  bucket    = var.website_name

  tags = {
    Name = "${var.website_name}-bucket"
  }
}

resource "aws_s3_bucket" "static_website_logging" {
  bucket    = "${var.website_name}-cflogs"

  tags = {
    Name = "${var.website_name}-bucket-cflogs"
  }
}

# Would prefer to have BucketOwnerEnforced as per AWS recommendations, but CloudFront Functions doesn't support it.
# Trade off is made and I think 10 million requests per second is preferable over arbitrary security given that it
# is a website serving public assets. AES256 also encrypts at rest.
resource "aws_s3_bucket_acl" "acl" {
  bucket    = aws_s3_bucket.static_website.id
  acl       = "private"
}

resource "aws_s3_bucket_acl" "acl_logging" {
  bucket    = aws_s3_bucket.static_website_logging.id
  acl       = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "static_website_bucket_policy" {
  bucket = aws_s3_bucket.static_website.id
  policy = data.aws_iam_policy_document.static_website_bucket_policy.json
}

resource "aws_s3_bucket_policy" "static_website_bucket_logging_policy" {
  bucket = aws_s3_bucket.static_website_logging.id
  policy = data.aws_iam_policy_document.static_website_bucket_logging_policy.json
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "static_website_logging" {
  bucket = aws_s3_bucket.static_website_logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_ownership_controls" "static_website_logging" {
  bucket = aws_s3_bucket.static_website_logging.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.static_website_bucket.id
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_website_logging" {
  bucket = aws_s3_bucket.static_website_logging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.static_website_logging_bucket.id
    }
  }
}

data "aws_iam_policy_document" "static_website_bucket_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.static_website.arn,
      format("%s/*", aws_s3_bucket.static_website.arn)
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.static_website_distribution.arn]
    }
  }
}

data "aws_iam_policy_document" "static_website_bucket_logging_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.static_website_logging.arn,
      format("%s/*", aws_s3_bucket.static_website_logging.arn)
    ]
  }
}