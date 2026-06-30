# Cache Subnet Group — tells Redis which private subnets to live in
resource "aws_elasticache_subnet_group" "main" {
  name       = "statusnest-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "statusnest-${var.environment}-redis-subnet-group"
    Environment = var.environment
  }
}

# Security Group — only allow Redis traffic (6379) from inside the VPC
resource "aws_security_group" "redis" {
  name        = "statusnest-${var.environment}-redis-sg"
  description = "Allow Redis access from within the VPC only"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis from within VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "statusnest-${var.environment}-redis-sg"
    Environment = var.environment
  }
}

# ElastiCache Redis Cluster (single node for dev — matches blueprint's t3.micro cost estimate)
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "statusnest-${var.environment}-redis"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = var.node_type
  num_cache_nodes      = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]
  apply_immediately    = true

  tags = {
    Name        = "statusnest-${var.environment}-redis"
    Environment = var.environment
  }
}