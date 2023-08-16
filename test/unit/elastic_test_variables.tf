# Variables usadas en la prueba
variable "region" {
  description = "Región en la que se llevarán a cabo las pruebas"
  type        = string
}

variable "vpc_cidr_block" {
  description = "Bloque CIDR de la VPC que se creará para la prueba"
  type        = string
}

variable "subnet1_cidr_block" {
  description = "Bloque CIDR que se definirá en la Subnet1 de prueba"
  type        = string
}

variable "subnet2_cidr_block" {
  description = "Bloque CIDR que se definirá en la Subnet2 de prueba"
  type        = string
}

variable "subnet1_availability_zone" {
  description = "Zona en la que se desplegará la Subnet1 de prueba"
  type        = string
}

variable "subnet2_availability_zone" {
  description = "Zona en la que se desplegará la Subnet2 prueba"
  type        = string
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