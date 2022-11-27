resource "aws_cloudwatch_metric_alarm" "function_execution_errors" {
  alarm_name          = "Function Execution Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FunctionExecutionErrors"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0.5"
  alarm_description   = "Function Execution Error rate 50% or higher"
  alarm_actions       = [aws_sns_topic.website_alerts.arn]
  ok_actions          = [aws_sns_topic.website_alerts.arn]
  dimensions = {
    DistributionId   = aws_cloudfront_distribution.static_website_distribution.id
  }
}