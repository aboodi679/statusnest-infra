# Placeholder secrets — real values get filled in when SMTP/webhook
# integrations are built (Day 11). Created now so naming, IAM scoping,
# and app config patterns are established early.

resource "aws_secretsmanager_secret" "smtp" {
  name = "statusnest-${var.environment}-smtp-credentials"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "smtp" {
  secret_id = aws_secretsmanager_secret.smtp.id
  secret_string = jsonencode({
    host     = "placeholder"
    port     = "587"
    username = "placeholder"
    password = "placeholder"
  })

  lifecycle {
    ignore_changes = [secret_string] # so future manual updates in AWS console aren't clobbered by terraform apply
  }
}

resource "aws_secretsmanager_secret" "webhook" {
  name = "statusnest-${var.environment}-webhook-secret"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "webhook" {
  secret_id     = aws_secretsmanager_secret.webhook.id
  secret_string = jsonencode({ signing_secret = "placeholder" })

  lifecycle {
    ignore_changes = [secret_string]
  }
}