variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID to deploy ECS tasks into"
  type        = string
}
variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}
variable "alb_security_group_id" {
  description = "ALB security group ID, to allow ALB -> ECS task traffic"
  type        = string
}
variable "container_port" {
  description = "Port the auth service container listens on"
  type        = number
  default     = 8000
}
variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}
variable "task_memory" {
  description = "Fargate task memory in MB"
  type        = string
  default     = "512"
}
variable "smtp_secret_arn" {
  description = "ARN of the SMTP credentials secret"
  type        = string
  default     = ""
}
variable "webhook_secret_arn" {
  description = "ARN of the webhook secret"
  type        = string
  default     = ""
}

variable "redis_url" {
  description = "Redis endpoint URL"
  type        = string
}
variable "jwt_secret_arn" {
  description = "ARN of the JWT secret in Secrets Manager"
  type        = string
}
variable "ecr_image_url" {
  description = "Full ECR image URL including tag"
  type        = string
}
variable "alb_target_group_arn" {
  description = "ALB target group ARN for the auth service"
  type        = string
}
variable "db_url_secret_arn" {
  description = "ARN of the DATABASE_URL secret in Secrets Manager"
  type        = string
}

resource "aws_iam_role" "ecs_task" {
  name = "statusnest-${var.environment}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "ecs_task_secrets" {
  name = "statusnest-${var.environment}-ecs-task-secrets-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [
        var.db_url_secret_arn,
        var.jwt_secret_arn,
      ]
    }]
  })
}
