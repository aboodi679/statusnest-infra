output "smtp_secret_arn" {
  value = aws_secretsmanager_secret.smtp.arn
}

output "webhook_secret_arn" {
  value = aws_secretsmanager_secret.webhook.arn
}