# Se especifica la versión del proveedor AWS necesario para la prueba
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Se configura el proveedor AWS, especificando la región para la prueba
provider "aws" {
  region = local.region
}

locals {

  # Definición de la región donde se llevarán a cabo las pruebas 
  region = "us-west-2"

  # Definición del bloque CIDR para la VPC que se generará para la prueba 
  vpc_cidr_block = "10.0.0.0/16"

  # Definición de los bloques CIDR para las subnets que se generarán para la prueba
  subnet1_cidr_block = "10.0.1.0/24"
  subnet2_cidr_block = "10.0.2.0/24"

  # Definición de la zonas de disponibilidad para las subnets que se generarán para la prueba
  subnet1_availability_zone = "us-west-2a"
  subnet2_availability_zone = "us-west-2b"

  # Variable para almacenar el valor de los identificadores de las subnets para la prueba
  subnets_id = {
    "snet-${local.partial_name}-1" = aws_subnet.subnet_test_1.id,
    "snet-${local.partial_name}-2" = aws_subnet.subnet_test_2.id
  }

  # Variable para almacenar el valor de los identificadores de los grupos de seguridad para la prueba
  security_groups_id = {
    "sg-${local.partial_name}-1" = aws_security_group.security_group_test_1.id,
    "sg-${local.partial_name}-2" = aws_security_group.security_group_test_2.id
  }

  # Familia de parámetros
  parameter_group_family = "memcached1.5"

  # Descripción del grupo de parámetros
  parameter_group_description = "Test Parameter Group Description"

  # Parámetros específicos del grupo
  parameter_group_parameters = {
    "chunk_size_growth_factor" = {
      name  = "chunk_size_growth_factor"
      value = "1.25"
    },
    "binding_protocol" = {
      name  = "binding_protocol"
      value = "ascii"
    }
  }

  # Motor utilizado para el cluster de ElastiCache
  engine = "memcached"

  # Versión del motor Memcached
  engine_version = "1.5.16"

  # Tipo de nodo para el cluster
  node_type = "cache.m4.large"

  # Número de nodos en el cluster
  num_cache_nodes = 2

  # Nombre del grupo de parámetros utilizado en la prueba
  parameter_group_name = "Test Parameter Group"

  # Modo de disponibilidad del cluster
  az_mode = "cross-az"

  # Nombre parcial para identificadores de recursos durante la prueba
  partial_name = "cluester-test"

  # Ambiente en el que se realizará la prueba
  environment = "dev"

  # Postfijo utilizado para verificar el nombrado recursos
  postfix_name = "${local.partial_name}-${local.environment}"

  # Etiquetas comunes a asignar a los recursos creados
  tags = {
    "Created_By"  = "HA"
    "Environment" = "Development"
  }

}

# Recurso para crear una VPC (Virtual Private Cloud) para la prueba
resource "aws_vpc" "vpc_test" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  # Aquí puedes agregar más configuración si es necesario
}

# Recurso para crear una subnet para la prueba
resource "aws_subnet" "subnet_test_1" {
  vpc_id            = aws_vpc.vpc_test.id
  cidr_block        = local.subnet1_cidr_block
  availability_zone = local.subnet1_availability_zone
  # Aquí puedes agregar más configuración si es necesario
}

# Recurso para crear una subnet para la prueba
resource "aws_subnet" "subnet_test_2" {
  vpc_id            = aws_vpc.vpc_test.id
  cidr_block        = local.subnet2_cidr_block
  availability_zone = local.subnet2_availability_zone
  # Aquí puedes agregar más configuración si es necesario
}

# Recurso para crear un grupo de seguridad para la prueba que permite tráfico HTTP
resource "aws_security_group" "security_group_test_1" {
  vpc_id = aws_vpc.vpc_test.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Aquí puedes agregar más configuración si es necesario
}

# Recurso para crear un grupo de seguridad para la prueba que permite tráfico SSH
resource "aws_security_group" "security_group_test_2" {
  vpc_id = aws_vpc.vpc_test.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Aquí puedes agregar más configuración si es necesario
}

# Modulo para configurar ElastiCache
module "elasticache" {
  source                      = "../../../Unity-ElaticCache-module"
  subnet_ids                  = local.subnets_id
  security_group_ids          = local.security_groups_id
  parameter_group_family      = local.parameter_group_family
  parameter_group_description = local.parameter_group_description
  parameter_group_parameters  = local.parameter_group_parameters
  engine                      = local.engine
  engine_version              = local.engine_version
  node_type                   = local.node_type
  num_cache_nodes             = local.num_cache_nodes
  parameter_group_name        = local.parameter_group_name
  az_mode                     = local.az_mode
  partial_name                = local.partial_name
  environment                 = local.environment
  tags                        = local.tags
}

# Región donde se realizaron las pruebas
output "aws_region" {
  description = "Región en la cual se han realizado las pruebas"
  value       = local.region
}

# Nombre del grupo de parámetros para la configuración de ElastiCache
output "cache_parameter_group_name" {
  description = "Nombre del grupo de parámetros utilizado en el cluster de ElastiCache"
  value       = "${local.engine}-ecpg-${local.postfix_name}"
}

# Nombre del grupo de subred para la configuración de ElastiCache
output "cache_subnet_group_name" {
  description = "Nombre del grupo de subred utilizado en el cluster de ElastiCache"
  value       = "${local.engine}-snetg-${local.postfix_name}"
}

# ID del cluster de ElastiCache creado
output "cache_cluster_id" {
  description = "ID del cluster de ElastiCache creado"
  value       = module.elasticache.elasticache_cluster_id
}

# Zonas de disponibilidad donde se encuentran las subredes
output "availability_zones" {
  description = "Zonas de disponibilidad donde se encuentran las subredes"
  value       = [local.subnet1_availability_zone, local.subnet2_availability_zone]
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