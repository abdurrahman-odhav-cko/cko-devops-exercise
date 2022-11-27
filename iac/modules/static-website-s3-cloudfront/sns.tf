resource "aws_sns_topic" "website_alerts" {
  name = "website-alerts-topic"
  kms_master_key_id = aws_kms_key.sns.key_id
}

resource "aws_sns_topic_subscription" "website_alerts" {
  endpoint  = var.email_address
  protocol  = "email"
  topic_arn = aws_sns_topic.website_alerts.arn
}