output "elasticache_cluster_id" {
  description = "Identificador del cluster de ElastiCache que se creó."
  value       = aws_elasticache_cluster.module_elasticache_cluster.cluster_id
}

output "elasticache_cluster_endpoint" {
  description = "Endpoint de del cluster ElastiCache creado."
  value       = aws_elasticache_cluster.module_elasticache_cluster.configuration_endpoint
}