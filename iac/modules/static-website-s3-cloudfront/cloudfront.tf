resource "aws_cloudfront_origin_access_control" "static_website_oac" {
  name                              = var.website_name
  description                       = "${var.website_name} Access Control Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "static_website_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.website_name} CloudFront Distribution"
  default_root_object = "index.html"

     logging_config {
       include_cookies = false
       bucket          = "${aws_s3_bucket.static_website_logging.bucket}.s3.amazonaws.com"
       prefix          = "cloudfront"
     }

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 900
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.static_website.arn
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

   tags = {
     Name = var.website_name
   }

  viewer_certificate {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [module.acm]

}

resource "aws_cloudfront_function" "static_website" {
  name    = "static_website"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite index to edge"
  publish = true
  code    = file("${path.module}/app.js")
}

resource "aws_cloudfront_response_headers_policy" "website_headers" {
  name = "${var.website_name}-headers-policy"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      override                   = true
    }
    content_security_policy {
      content_security_policy = "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override                = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = false
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }
  }
  custom_headers_config {
    items {
      header   = "X-Permitted-Cross-Domain-Policies"
      override = true
      value    = "none"
    }
  }

  server_timing_headers_config {
    enabled       = true
    sampling_rate = 50
  }
}