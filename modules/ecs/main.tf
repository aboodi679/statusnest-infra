resource "aws_ecs_cluster" "main" {
  name = "statusnest-${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
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

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "statusnest-${var.environment}-ecs-secrets-policy"
  role = aws_iam_role.ecs_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [
        var.db_url_secret_arn,
        var.jwt_secret_arn
      ]
    }]
  })
}

resource "aws_cloudwatch_log_group" "auth" {
  name              = "/ecs/statusnest-${var.environment}-auth"
  retention_in_days = 7
  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "auth" {
  family                   = "statusnest-${var.environment}-auth"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions = jsonencode([
    {
      name      = "auth"
      image     = var.ecr_image_url
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "JWT_ALGORITHM",      value = "HS256" },
        { name = "JWT_EXPIRE_MINUTES", value = "30"   }
      ]
      secrets = [
        { name = "JWT_SECRET",    valueFrom = "${var.jwt_secret_arn}:value::" },
        { name = "DATABASE_URL",  valueFrom = var.db_url_secret_arn }
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

resource "aws_ecs_service" "auth" {
  name            = "statusnest-${var.environment}-auth"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "auth"
    container_port   = var.container_port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_execution]

  lifecycle {
    ignore_changes = [task_definition]
  }
}
