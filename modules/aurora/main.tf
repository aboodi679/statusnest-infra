# Random password for DB master user
resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the password in Secrets Manager — never in plaintext anywhere else
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "statusnest-${var.environment}-db-credentials"
  description = "RDS master credentials for StatusNest ${var.environment}"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = 5432
    dbname   = var.db_name
  })
}

# DB Subnet Group — tells RDS which private subnets to live in
resource "aws_db_subnet_group" "main" {
  name       = "statusnest-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "statusnest-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Security Group — only allow PostgreSQL traffic (5432) from inside the VPC
resource "aws_security_group" "aurora" {
  name        = "statusnest-${var.environment}-db-sg"
  description = "Allow PostgreSQL access from within the VPC only"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from within VPC"
    from_port   = 5432
    to_port     = 5432
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
    Name        = "statusnest-${var.environment}-db-sg"
    Environment = var.environment
  }
}

# RDS PostgreSQL Instance (Free Tier eligible: db.t4g.micro / db.t3.micro)
resource "aws_db_instance" "main" {
  identifier             = "statusnest-${var.environment}-db"
  engine                 = "postgres"
 engine_version         = "17.10"
  instance_class         = var.instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.master_username
  password               = random_password.master.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  multi_az                = false
  publicly_accessible     = false
  storage_encrypted       = true
  skip_final_snapshot     = var.environment == "dev" ? true : false
  backup_retention_period = var.environment == "dev" ? 1 : 7

  tags = {
    Name        = "statusnest-${var.environment}-db"
    Environment = var.environment
  }
}