variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy Redis into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the cache subnet group"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used to scope security group access"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t4g.micro"
}