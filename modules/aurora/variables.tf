variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the database into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used to scope security group access"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "statusnest"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "statusnest_admin"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}