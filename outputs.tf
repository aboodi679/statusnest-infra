output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "aurora_cluster_endpoint" {
  value = module.aurora.cluster_endpoint
}

output "aurora_secret_arn" {
  value = module.aurora.secret_arn
}
output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "redis_port" {
  value = module.elasticache.redis_port
}