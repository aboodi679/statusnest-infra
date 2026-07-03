output "redis_endpoint" {
  description = "Redis cluster endpoint address"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}
output "redis_port" {
  value = aws_elasticache_cluster.main.port
}
output "security_group_id" {
  value = aws_security_group.redis.id
}
output "cluster_id" {
  value = aws_elasticache_cluster.main.cluster_id
}
