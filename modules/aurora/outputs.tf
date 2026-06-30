output "cluster_endpoint" {
  description = "Endpoint for the database"
  value       = aws_db_instance.main.address
}

output "cluster_id" {
  value = aws_db_instance.main.id
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "security_group_id" {
  value = aws_security_group.aurora.id
}