resource "aws_route53_record" "route53" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.static_website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_website_distribution.hosted_zone_id
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.2.0"
  providers = {
    aws = aws.us-east-1
  }


  domain_name = var.domain_name
  zone_id     = var.zone_id

  subject_alternative_names = var.sans

  wait_for_validation = true

  tags = {
    Name = "${var.website_name}-acm"
  }
}