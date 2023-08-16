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

  # Etiquetas comunes a asignar a los recursos creados
  tags = {
    "Created_By"  = "HA"
    "Environment" = "Development"
  }