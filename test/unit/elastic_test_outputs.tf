# Región donde se realizaron las pruebas
output "aws_region" {
  description = "Región en la cual se han realizado las pruebas"
  value       = var.region
}

# Nombre del grupo de parámetros para la configuración de ElastiCache
output "cache_parameter_group_name" {
  description = "Nombre del grupo de parámetros utilizado en el cluster de ElastiCache"
  value       = "${var.engine}-ecpg-${local.postfix_name}"
}

# Nombre del grupo de subred para la configuración de ElastiCache
output "cache_subnet_group_name" {
  description = "Nombre del grupo de subred utilizado en el cluster de ElastiCache"
  value       = "${var.engine}-snetg-${local.postfix_name}"
}

# ID del cluster de ElastiCache creado
output "cache_cluster_id" {
  description = "ID del cluster de ElastiCache creado"
  value       = module.elasticache.elasticache_cluster_id
}

# Zonas de disponibilidad donde se encuentran las subredes
output "availability_zones" {
  description = "Zonas de disponibilidad donde se encuentran las subredes"
  value       = [var.subnet1_availability_zone, var.subnet2_availability_zone]
}

# IDs de las subredes utilizadas en los recursos creados
output "subnets" {
  description = "IDs de las subredes utilizadas en los recursos creados"
  value       = values(local.subnets_id)
}

# IDs de los grupos de seguridad asociados a los recursos creados
output "security_groups" {
  description = "IDs de los grupos de seguridad asociados a los recursos creados"
  value       = values(local.security_groups_id)
}