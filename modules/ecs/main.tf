resource "aws_ecs_cluster" "main" {
  name = "statusnest-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled" # avoid extra CloudWatch charges in dev
  }

  tags = {
    Name        = "statusnest-${var.environment}-cluster"
    Environment = var.environment
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "statusnest-${var.environment}-ecs-tasks-sg"
  description = "Allow traffic from ALB only to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "statusnest-${var.environment}-ecs-tasks-sg"
    Environment = var.environment
  }
}

# Placeholder execution role — least-privilege IAM comes properly on Day 5.
# This is the minimum AWS-managed policy needed for ECS to pull images/write logs.
resource "aws_iam_role" "ecs_execution" {
  name = "statusnest-${var.environment}-ecs-execution-role"

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

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "auth" {
  name              = "/ecs/statusnest-${var.environment}-auth"
  retention_in_days = 7 # keep short in dev to control cost

  tags = {
    Environment = var.environment
  }
}

# Task definition skeleton — image is a placeholder until Day 6 builds the real auth service
resource "aws_ecs_task_definition" "auth" {
  family                   = "statusnest-${var.environment}-auth"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "auth"
      image     = "public.ecr.aws/docker/library/httpd:latest" # placeholder, swapped on Day 6
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.auth.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "auth"
        }
      }
    }
  ])

  tags = {
    Environment = var.environment
  }
}


# NOTE: No aws_ecs_service resource yet — intentionally deferred to Day 6
# when the real auth service image exists in ECR. Creating a running
# service now would incur Fargate compute charges for an idle placeholder.