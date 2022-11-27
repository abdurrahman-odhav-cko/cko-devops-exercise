locals {
  s3_origin_id = "S3Origin"
  kms_keys = {
    static_website_bucket = {
      description = "Static Website Bucket for CloudFront for wStatic Website Bucket for CloudFront Distribution ${var.website_name}ebsite ${var.website_name}"
      policy  = data.aws_iam_policy_document.static_website_bucket_policy.json
    }
  }
}