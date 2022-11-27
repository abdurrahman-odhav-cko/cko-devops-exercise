data "aws_caller_identity" "current" {}

data "aws_route53_zone" "odhav_com" {
  name = "odhav.com."
}