# Módulo de Terraform para crear un clúster de AWS ElastiCache

Este módulo crea un clúster de instancias ElastiCache en AWS, que incluye la creación de un grupo de parámetros ElastiCache y un grupo de subnets ElastiCache.

## Características

-  Permite definir un conjunto de parámetros específicos a través de `parameter_group_name` para especificar el comportamiento del clúster de ElastiCache.

- Proporciona la capacidad de especificar un conjunto de subnets a través de `subnet_ids` en las que se alojará el clúster de ElastiCache.

- Proporciona la capacidad de especificar un conjunto de grupos de seguridad a través de `security_group_ids`, dichos grupos de seguridad se asociarán al clúster de ElastiCache.

- Crea un clúster de ElastiCache en el que se puede seleccionar el motor de base de datos a través de `engine`, la versión del motor a través de `engine_version`, el tipo de nodo a través de `node_type` y la cantidad de nodos de caché a través de `num_cache_nodes`.

- Permite asignar las etiquetas especificadas en `tags` a todos los recursos generados, incluyendo la etiqueta `Name` implementando una convención de nombrado estándarizado para los recursos.

## Uso

```hcl
module "elasticache" {
  source = "<ruta al módulo>"

  subnet_ids             = ["subnet-0a3507a5ad2c5c8c3", "subnet-0b12a8d5566830e67"]
  security_group_ids     = ["sg-0a3df2b67a3fa5a2a"]
  parameter_group_family = "memcached1.5"
  parameter_group_description = "Grupo de parametros para memcached"
  parameter_group_parameters = {
    "chunk_size_growth_factor" = {
      name  = "chunk_size_growth_factor"
      value = "1.25"
    }
    "max_packet_size" = {
      name  = "max_packet_size"
      value = "262144"
    }
    ...
  }

  engine             = "memcached"
  engine_version     = "1.5.16"
  node_type          = "cache.m4.large"
  num_cache_nodes    = 1
  parameter_group_name = "default.memcached1.5"
  az_mode            = "cross-az"
  partial_name       = "redis-example"
  environment        = "prod"
  
  tags = {
    "Environment" = "Production"
    "Created_by"  = "HA"
    ...
  }
}
```

## Variables de entrada

El módulo tiene las siguientes variables de entrada:

- `subnet_ids` - Mapa de identificadores de las subnets donde el clúster de ElastiCache será creado. Cada elemento del mapa es identificado por el nombre de la subnet. 

- `security_group_ids` - Mapa de identificadores de los grupos de seguridad que se asignarán al clúster de ElastiCache. Cada elemento del mapa es identificado por el nombre del grupo se seguridad.

- `parameter_group_name` - Nombre del grupo de parámetros para el clúster de ElastiCache.

- `parameter_group_family`: Familia del grupo de parámetros para el clúster de ElastiCache.

- `parameter_group_description` - Descripción del grupo de parámetros del clúster de ElastiCache.

- `parameter_group_parameters` - Mapa de parámetros a asignar al grupo de parámetros de ElastiCache.  Cada parámetro está representado por un objeto con los siguientes atributos:

  - `name` - 
    
  - `value` - 

- `engine` - Motor de la base de datos que se utilizará en la creación del clúster de ElastiCache (memcached/redis).

- `engine_version` - Versión del motor de la base de datos que se utilizará en la creación del clúster de ElastiCache.

- `node_type` - Tipo de nodo que el clúster de ElastiCache utilizará.

- `num_cache_nodes` - Número de nodos de caché para el clúster de ElastiCache.

- `az_mode` - Modo de disponibilidad del clúster de ElasticCache (single-az o cross-az).

- partial_name - Variable utilizada para el nombrado estándar de los recursos.

- `environment` - Variable utilizada para el nombrado estándar de los recursos.

- `tags` - Mapa de etiquetas para asignar a la instancia.

## Variables de salida

El módulo tiene las siguientes variables de salida:

- elasticache_cluster_id: Identificador del clúster de ElastiCache que se creó.

- elasticache_cluster_endpoint: Endpoint de del clúster ElastiCache creado.

## Recursos creados

Este módulo crea los siguientes recursos:

- Un grupo de parámetros de ElastiCache.

- Un grupo de subredes de ElastiCache.

- Un clúster de ElastiCache.

## Dependencias

Este módulo depende de los siguientes recursos:

- Subnets existentes especificadas por `subnet_id`.

- Grupos de seguridad existentes especificados por `security_groups_ids`.

## Consideraciones

Ninguna.