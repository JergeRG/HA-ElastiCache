variable "subnet_ids" {
  description = "El conjunto de identificadores de las subnets donde la instancia de ElastiCache será creada."
  type        = set(string)
}

variable "security_group_ids" {
  description = "El conjunto de identificadores de los grupos de seguridad que se asignarán a la instancia de ElastiCache."
  type        = set(string)
}

variable "parameter_group_family" {
  description = "La familia del grupo de parámetros para la instancia ElastiCache."
  type        = string
}

variable "parameter_group_description" {
  description = "Descripción del grupo de parámetros de la instancia ElastiCache"
  type        = string
}

variable "parameter_group_parameters" {
  description = "Mapa de parámetros a asignar al grupo de parámetros de ElastiCache."
  type = map(object({
    name  = string
    value = string
  }))
}

variable "engine" {
  description = "El motor de la base de datos que se utilizará en la creación de la instancia ElastiCache (memcached/redis)."
  type        = string
}

variable "engine_version" {
  description = "Versión del motor de la base de datos que se utilizará en la creación de la instancia ElastiCache."
}

variable "node_type" {
  description = "El tipo de nodo que la instancia de ElastiCache utilizará."
  type        = string
}

variable "num_cache_nodes" {
  description = "El número de nodos de caché para el clúster de ElastiCache."
  type        = number
}

variable "parameter_group_name" {
  description = "El nombre del grupo de parámetros para la instancia de ElastiCache."
  type        = string
}

variable "az_mode" {
  description = "Modo de disponibilidad de la instancia ElasticCache (single-az o cross-az)."
  type = string
}

variable "partial_name" {
  description = "Variable utilizada para el nombrado estándar de los recursos (ENGINE-ec-ENVIRONMENT)"
  type        = string
}

variable "environment" {
  description = "Variable utilizada para el nombrado estándar de los recursos (ENGINE-ec-ENVIRONMENT)"
  type        = string
}


variable "tags" {
  description = "Etiquetas base para el recurso, adicionalmente se asignará la etiqueta Name"
  type        = map(string)
}