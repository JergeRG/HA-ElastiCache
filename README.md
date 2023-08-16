# Módulo de Terraform para crear un clúster de AWS ElastiCache

Este módulo crea un clúster de instancias ElastiCache en AWS, que incluye la creación de un grupo de parámetros ElastiCache y un grupo de subnets ElastiCache.

- [Características](#características)
- [Uso](#uso)
- [Variables de Entrada](#variables-de-entrada)
- [Variables de Salida](#variables-de-salida)
- [Recursos Creados](#recursos-creados)
- [Dependencias](#dependencias)
- [Pruebas](#pruebas)
- [Configuración del Pre-Commit Hook](#configuración-del-pre-commit-hook)
- [Consideraciones](#consideraciones)

## Características

-  Permite definir un conjunto de parámetros específicos a través de `parameter_group_name` para especificar el comportamiento del clúster de ElastiCache.

- Proporciona la capacidad de especificar un conjunto de subnets a través de `subnet_ids` en las que se alojará el clúster de ElastiCache.

- Proporciona la capacidad de especificar un conjunto de grupos de seguridad a través de `security_group_ids`, dichos grupos de seguridad se asociarán al clúster de ElastiCache.

- Crea un clúster de ElastiCache en el que se puede seleccionar el motor de base de datos a través de `engine`, la versión del motor a través de `engine_version`, el tipo de nodo a través de `node_type` y la cantidad de nodos de caché a través de `num_cache_nodes`.

- Permite asignar las etiquetas especificadas en `tags` a todos los recursos generados, incluyendo la etiqueta `Name` implementando una convención de nombrado estándarizado para los recursos.

## Uso

```hcl
module "elasticache" {
  source                   = "<ruta al módulo>"
  subnet_ids               = {
    snet-eg-1 = "subnet-0a3507a5ad2c5c8c3"
    snet-eg-2 = "subnet-0b12a8d5566830e67"
    ...
  }
  security_group_ids       = {
    "sg-eg-1" = "sg-0a3df2b67a3fa5a2a"
    "sg-eg-2" = "sg-454sdsfs3g145gdgs"
    ...
  }
  parameter_group_family   = "memcached1.5"
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
  engine                   = "memcached"
  engine_version           = "1.5.16"
  node_type                = "cache.m4.large"
  num_cache_nodes          = 1
  parameter_group_name     = "default.memcached1.5"
  az_mode                  = "cross-az"
  partial_name             = "redis-example"
  environment              = "prod"
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

  - `name` -  El nombre del parámetro. Es un identificador único dentro del grupo de parámetros.
    
  - `value` - El valor que se asignará al parámetro.

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

- elasticache_cluster_id - Identificador del clúster de ElastiCache que se creó.

- elasticache_cluster_endpoint - Endpoint del clúster ElastiCache creado.

## Recursos creados

Este módulo crea los siguientes recursos:

- Un grupo de parámetros de ElastiCache.

- Un grupo de subredes de ElastiCache.

- Un clúster de ElastiCache.

## Dependencias

Este módulo depende de los siguientes recursos:

- Subnets existentes especificadas por `subnet_id`.

- Grupos de seguridad existentes especificados por `security_groups_ids`.

## Pruebas

Este módulo incorpora pruebas unitarias desarrolladas con `Terratest`, utilizando el marco de pruebas `Go`. Las pruebas se encuentran en el directorio `test`. Para su ejecución, deben seguirse los siguientes pasos:

1. Hay que asegurarse de que la versión `>=1.19` de `Go` esté instalada en la máquina donde se llevarán a cabo las pruebas.

2. Se debe de navegar hasta el directorio `test` dentro del repositorio.
    ```bash
    cd test
3. Se debe de ejecutar el siguiente comando:
    ```bash
    go test -v -timeout 20m
    ```
    La opción `-v` ofrece una salida detallada, útil para comprender qué ocurre durante la prueba. La opción `-timeout`  define la duración máxima que puede tomar la prueba (ejemplo, `10m` para 10 minutos o `1h` para una hora).

    #### Nota
    Deben configurarse las credenciales de AWS correspondientes, ya que la prueba implica la creación de infraestructura real en una cuenta de AWS, lo cual podría incurrir en cargos.

En caso de requerir cambios en los valores de la prueba, deben modificarse los siguientes archivos:

- `test/elastic_test.go` - Este archivo debe ser modificado si se necesitan cambios en las validaciones realizadas sobre la configuración.

- `test/unit/elastic_test.tf` - Este archivo debe ser modificado si es necesario hacer cambios en la creación de los recursos para la prueba.

- `test/unit/elastic_test_variables.tf` - Si es necesario hacer cambios en las variables de entrada que se toman en cuenta para la prueba, se debe ajustar este archivo.

- `test/unit/elastic_test.tfvars` - Este archivo debe ser modificado si se requieren ajustes en los valores de las variables usadas para la prueba.

- `test/unit/elastic_test_outputs.tf` - Si es necesario hacer cambios en las variables de salida que se toman en cuenta para la prueba, se debe ajustar este archivo. Al agregar o eliminar variables, es imprescindible realizar las modificaciones correspondientes en el archivo `test/elastic_test.go`.

Para más información sobre la configuración y modificación de las pruebas, consultar la [Documentación de Terratest](https://terratest.gruntwork.io/docs/). 

## Configuración del Pre-Commit Hook

Este proyecto emplea un pre-commit hook on el objetivo de asegurar que los archivos de Terraform sean correctamente formateados y validados antes de cada commit. Para su configuración, deben seguirse estos pasos:

1. Hay que asegurarse de que `Terraform` esté instalado en la máquina donde se utilizará el `pre-commit`, ya que el script emplea `terraform fmt` y `terraform validate` para las validaciones.

2. Se debe de copiar el archivo `pre-commit` del directorio `hooks` a `.git/hooks`:
   ```bash
   copy hooks\pre-commit .git\hooks\pre-commit
Al realizar un commit, el pre-commit hook verificará automáticamente los archivos de Terraform en espera de commit, los formateará con `terraform fmt`, y los validará con `terraform validate`. Si alguna de estas verificaciones falla, se detendrá el commit, permitiendo corregir los errores antes de continuar.
Cuando realice un commit, el pre-commit hook verificará automáticamente los archivos de Terraform en espera de commit, los formateará con `terraform fmt`, y los validará con `terraform validate`. Si alguna de estas verificaciones falla, el commit se detendrá, permitiéndole corregir los errores antes de continuar.

## Consideraciones

- Se deben especificar por lo menos dos subnets en diferentes zonas de disponibilidad para la creación del grupo de subnets.

- El grupo de parámetros debe definirse cuidadosamente y debe alinearse al motor de la instancia, ya que estos parámetros afectarán la configuración y el rendimiento de la instancia ElastiCache.

- La elección del motor es esencial. Las opciones disponibles son `memcached` y `redis`, y cada una tiene características y comportamientos específicos.

- El tipo de nodo  y el número de nodos de caché determinarán el rendimiento y los costos asociados con la instancia.
