variable "environment" {}
variable "alert_email" {}

# SNS Topic
resource "aws_sns_topic" "alerts" {
  name = "statusnest-${var.environment}-alerts"
  tags = { Environment = var.environment }
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# SES Email Identity
resource "aws_ses_email_identity" "alert_sender" {
  email = var.alert_email
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "ses_identity_arn" {
  value = aws_ses_email_identity.alert_sender.arn
}