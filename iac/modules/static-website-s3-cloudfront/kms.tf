resource "aws_kms_key" "static_website_bucket" {
  description             = "Static Website Bucket for CloudFront Distribution ${var.website_name}"
  deletion_window_in_days = 7
  policy = data.aws_iam_policy_document.static_website_bucket_kms.json
}

resource "aws_kms_key" "static_website_logging_bucket" {
  description             = "Static Website Logging Bucket for CloudFront Distribution ${var.website_name}"
  deletion_window_in_days = 7
  policy = data.aws_iam_policy_document.static_website_logging_bucket_kms.json
}

resource "aws_kms_key" "sns" {
  description             = "SNS Notifier for CloudWatch alarms"
  deletion_window_in_days = 7
  policy = data.aws_iam_policy_document.sns_kms.json
}

data "aws_iam_policy_document" "static_website_bucket_kms" {
  statement {
    actions = [
      "kms:*"
    ]
    resources = [
    "*"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        var.role_arn
      ]
      type        = "AWS"
    }
  }
  statement {
    actions = [
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
   }
  }
}

data "aws_iam_policy_document" "static_website_logging_bucket_kms" {
  statement {
    actions = [
      "kms:GenerateDataKey*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
  }
  statement {
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        var.role_arn
      ]
      type        = "AWS"
    }
  }
}

data "aws_iam_policy_document" "sns_kms" {
  statement {
    actions = [
      "kms:GenerateDataKey*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
  }
  statement {
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        var.role_arn
      ]
      type        = "AWS"
    }
  }
}


