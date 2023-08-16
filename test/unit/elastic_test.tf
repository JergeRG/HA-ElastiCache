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
  region = var.region
}

locals {

# Postfijo utilizado para verificar el nombrado recursos de prueba
  postfix_name = "${var.partial_name}-${var.environment}"

  # Variable para almacenar el valor de los identificadores de las subnets para la prueba
  subnets_id = {
    "snet-${var.partial_name}-1" = aws_subnet.subnet_test_1.id,
    "snet-${var.partial_name}-2" = aws_subnet.subnet_test_2.id
  }

  # Variable para almacenar el valor de los identificadores de los grupos de seguridad para la prueba
  security_groups_id = {
    "sg-${var.partial_name}-1" = aws_security_group.security_group_test_1.id,
    "sg-${var.partial_name}-2" = aws_security_group.security_group_test_2.id
  }
}

# Recurso para crear una VPC (Virtual Private Cloud) para la prueba
resource "aws_vpc" "vpc_test" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Recurso para crear una subnet para la prueba
resource "aws_subnet" "subnet_test_1" {
  vpc_id            = aws_vpc.vpc_test.id
  cidr_block        = var.subnet1_cidr_block
  availability_zone = var.subnet1_availability_zone
}

# Recurso para crear una subnet para la prueba
resource "aws_subnet" "subnet_test_2" {
  vpc_id            = aws_vpc.vpc_test.id
  cidr_block        = var.subnet2_cidr_block
  availability_zone = var.subnet2_availability_zone
}

# Recurso para crear un grupo de seguridad para la prueba que permite tráfico HTTP
resource "aws_security_group" "security_group_test_1" {
  vpc_id = aws_vpc.vpc_test.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Recurso para crear un grupo de seguridad para la prueba que permite tráfico SSH
resource "aws_security_group" "security_group_test_2" {
  vpc_id = aws_vpc.vpc_test.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Modulo para configurar ElastiCache
module "elasticache" {
  source                      = "../../../Unity-ElaticCache-module"
  subnet_ids                  = local.subnets_id
  security_group_ids          = local.security_groups_id
  parameter_group_family      = var.parameter_group_family
  parameter_group_description = var.parameter_group_description
  parameter_group_parameters  = var.parameter_group_parameters
  engine                      = var.engine
  engine_version              = var.engine_version
  node_type                   = var.node_type
  num_cache_nodes             = var.num_cache_nodes
  parameter_group_name        = var.parameter_group_name
  az_mode                     = var.az_mode
  partial_name                = var.partial_name
  environment                 = var.environment
  tags                        = var.tags
}