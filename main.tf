# Recupera la información de las subnets existentes a partir del identificadores especificados en 'var.subnet_ids'.
data "aws_subnet" "module_subnets" {
  for_each = var.subnet_ids
  id = each.value
}

# Recupera la información de los grupos de seguridad existentes a partir de los identificadores especificados en 'var.security_group_ids'.
data "aws_security_group" "module_security_groups" {
  for_each = var.security_group_ids
  id       = each.value
}

# Define una variable local que se usará como sufijo en los nombres de los recursos.
locals {
  postfix_name = "${var.partial_name}-${var.environment}"
}

# Crea un grupo de parámetros ElastiCache con un nombre basado en el motor especificado y la variable 'local.postfix_name'.
# El grupo de parametros será especificado con la familia especificada en 'var.parameter_group_family' y la descripción especificada en 'var.parameter_group_description'.
resource "aws_elasticache_parameter_group" "module_elasticache_parameter_group" {
  name        = "${var.engine}-ecpg-${local.postfix_name}"
  family      = var.parameter_group_family
  description = var.parameter_group_description

  # Añade los parámetros especificados en 'parameter_group_parameters' de forma dinámica.
  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
  # Define las etiquetas para el recurso, incluyendo una etiqueta 'Name'.
  tags = merge(var.tags, {
    "Name" = "${var.engine}-ecpg-${local.postfix_name}"
  })

}


# Crea un grupo de subnets ElastiCache con un nombre basado en el motor especificado en 'var.engine' y la variable local 'local.postfix_name'.
# Al grupo de las subnets le asigna los identificadores especificados en 'data.aws_subnet.module_subnets'
resource "aws_elasticache_subnet_group" "module_elasticache_subnet_group" {
  name = "${var.engine}-snetg-${local.postfix_name}"
  subnet_ids   = tolist(values(data.aws_subnet.module_subnets)[*].id)

  # Define las etiquetas para el recurso, incluyendo una etiqueta 'Name'.
  tags = merge(var.tags, {
    "Name" = "${var.engine}-snetg-${local.postfix_name}"
  })
}

# Crea un clúster de ElastiCache con un nombre basado en el motor especificado en 'var.engine' y asigna las configuraciones requeridas.
resource "aws_elasticache_cluster" "module_elasticache_cluster" {
  cluster_id           = "${var.engine}-ec-${local.postfix_name}"
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.module_elasticache_parameter_group.name
  az_mode              = var.az_mode
  subnet_group_name    = aws_elasticache_subnet_group.module_elasticache_subnet_group.name
  security_group_ids   = tolist(values(data.aws_security_group.module_security_groups)[*].id) 

  # Define las etiquetas para el recurso, incluyendo una etiqueta 'Name'.
  tags = merge(var.tags, {
    "Name" = "${var.engine}-ec-${local.postfix_name}"
  })

  # Especifica una dependencia explícita con el grupo de subnets y el grupo de parametros para crear el recurso posterior a las dependencias.
  depends_on = [ 
    aws_elasticache_parameter_group.module_elasticache_parameter_group,
    aws_elasticache_subnet_group.module_elasticache_subnet_group
  ]
}
