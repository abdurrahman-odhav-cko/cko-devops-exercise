module "cko_devops_exercise" {
  source = "./modules/static-website-s3-cloudfront"

  website_name     = "aodhav-cko-devops-exercise"
  domain_name      = "cko-devops-exercise.odhav.com"
  hosted_zone_name = data.aws_route53_zone.odhav_com.name
  zone_id          = data.aws_route53_zone.odhav_com.zone_id
  role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/aodhav"
  email_address    = "abdurrahman@odhav.com"
}