output "smtp_secret_arn" {
  value = aws_secretsmanager_secret.smtp.arn
}

output "webhook_secret_arn" {
  value = aws_secretsmanager_secret.webhook.arn
}
output "jwt_secret_arn" {
  value = aws_secretsmanager_secret.jwt_secret.arn
}

output "db_url_secret_arn" {
  value = aws_secretsmanager_secret.db_url.arn
}
