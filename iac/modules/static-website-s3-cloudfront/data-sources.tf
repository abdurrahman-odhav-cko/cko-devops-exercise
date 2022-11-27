data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_route53_zone" "zone" {
  name         = var.hosted_zone_name
  private_zone = false
}