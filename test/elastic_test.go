package test

import (
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/elasticache"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestElastiCacheResources(t *testing.T) {
	t.Parallel() // Permite que la prueba se ejecute en paralelo con otras pruebas

	// Configuración de las opciones de Terraform para el directorio que contiene la configuración de Terraform
	options := &terraform.Options{
		TerraformDir: "unit",
	}

	// Limpia los recursos creados por Terraform después de que la prueba haya terminado
	defer terraform.Destroy(t, options)

	// Inicializa y aplica la configuración de Terraform
	terraform.InitAndApply(t, options)

	// Obtiene las salidas de Terraform para la region, el nombre del grupo de parámetros que se asociará al clúster,
	// el nombre del grupo de subnets que se asociará al clúster, el identificador del clúster a crear
	// y, los grupos de seguridad, las zonas de disponibilidad y las subnets que se espera que se asocien al clúster.
	awsRegion := terraform.Output(t, options, "aws_region")
	cacheParameterGroupName := terraform.Output(t, options, "cache_parameter_group_name")
	cacheSubnetGroupName := terraform.Output(t, options, "cache_subnet_group_name")
	cacheClusterID := terraform.Output(t, options, "cache_cluster_id")
	expectedAvailabilityZones := terraform.OutputList(t, options, "availability_zones")
	expectedSubnets := terraform.OutputList(t, options, "subnets")
	expectedSecurityGroups := terraform.OutputList(t, options, "security_groups")

	// Crea una nueva sesión de AWS en la región deseada
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	}))

	// Crea un nuevo servicio de ElastiCache
	elasticacheSvc := elasticache.New(sess)

	// Verifica el grupo de parámetros de ElastiCache
	parameterGroup := describeCacheParameterGroup(t, elasticacheSvc, cacheParameterGroupName)
	assert.NotNil(t, parameterGroup, "No se creo el grupo de parámetros especificado en la configuración")

	// Verifica el grupo de subredes de ElastiCache
	subnetGroup := describeCacheSubnetGroup(t, elasticacheSvc, cacheSubnetGroupName)
	assert.NotNil(t, subnetGroup, "No se creo el grupo de subredes especificado en la configuración")

	// Verifica el clúster de ElastiCache
	cluster := describeCacheCluster(t, elasticacheSvc, cacheClusterID)
	assert.NotNil(t, cluster, "No se creo el cluster como se definio en la configuración")

	// Verifica que el clúster se creó en las zonas de disponibilidad correctas
	actualZones := verifyAvailabilityZones(t, elasticacheSvc, cluster, expectedAvailabilityZones)
	assert.ElementsMatch(t, expectedAvailabilityZones, actualZones, "El clúster no se creo en las zonas de disponibilidad esperadas")

	// Verifica que el clúster se creó en las subredes correctas
	actualSubnets := verifySubnets(t, elasticacheSvc, cluster, expectedSubnets)
	assert.ElementsMatch(t, expectedSubnets, actualSubnets, "El clúster no se creo en las subnets esperadas")

	// Verifica los grupos de seguridad
	actualSecurityGroups := verifySecurityGroups(t, elasticacheSvc, cluster, expectedSecurityGroups)
	assert.ElementsMatch(t, expectedSecurityGroups, actualSecurityGroups, "Los grupos de seguridad asociados al clúster no coinciden con los definidos en la configuración")
}

// Función para describir el grupo de parámetros de ElastiCache
func describeCacheParameterGroup(t *testing.T, svc *elasticache.ElastiCache, name string) *elasticache.CacheParameterGroup {
	input := &elasticache.DescribeCacheParameterGroupsInput{
		CacheParameterGroupName: aws.String(name),
	}
	output, err := svc.DescribeCacheParameterGroups(input)
	assert.NoError(t, err)
	return output.CacheParameterGroups[0]
}

// Función para describir el grupo de subredes de ElastiCache
func describeCacheSubnetGroup(t *testing.T, svc *elasticache.ElastiCache, name string) *elasticache.CacheSubnetGroup {
	input := &elasticache.DescribeCacheSubnetGroupsInput{
		CacheSubnetGroupName: aws.String(name),
	}
	output, err := svc.DescribeCacheSubnetGroups(input)
	assert.NoError(t, err)
	return output.CacheSubnetGroups[0]
}

// Función para describir el clúster de ElastiCache
func describeCacheCluster(t *testing.T, svc *elasticache.ElastiCache, clusterID string) *elasticache.CacheCluster {
	input := &elasticache.DescribeCacheClustersInput{
		CacheClusterId: aws.String(clusterID),
	}
	output, err := svc.DescribeCacheClusters(input)
	assert.NoError(t, err)
	return output.CacheClusters[0]
}

// Función para verificar las zonas de disponibilidad del clúster
func verifyAvailabilityZones(t *testing.T, svc *elasticache.ElastiCache, cluster *elasticache.CacheCluster, expectedZones []string) []string {
	// Obtiene el grupo de subredes asociado con el clúster
	subnetGroup := describeCacheSubnetGroup(t, svc, *cluster.CacheSubnetGroupName)

	// Extrae las zonas de disponibilidad de las subredes
	actualZones := []string{}
	for _, subnet := range subnetGroup.Subnets {
		actualZones = append(actualZones, *subnet.SubnetAvailabilityZone.Name)
	}
	return actualZones
}

// Función para verificar las subredes del clúster
func verifySubnets(t *testing.T, svc *elasticache.ElastiCache, cluster *elasticache.CacheCluster, expectedSubnets []string) []string {
	// Obtiene el grupo de subredes asociado con el clúster
	subnetGroup := describeCacheSubnetGroupComp(t, svc, *cluster.CacheSubnetGroupName)

	// Extrae las subredes
	actualSubnets := []string{}
	for _, subnet := range subnetGroup.Subnets {
		actualSubnets = append(actualSubnets, *subnet.SubnetIdentifier)
	}
	return actualSubnets
}

// Función complementaria para describir el grupo de subredes de ElastiCache
func describeCacheSubnetGroupComp(t *testing.T, svc *elasticache.ElastiCache, subnetGroupName string) *elasticache.CacheSubnetGroup {
	input := &elasticache.DescribeCacheSubnetGroupsInput{
		CacheSubnetGroupName: aws.String(subnetGroupName),
	}
	result, err := svc.DescribeCacheSubnetGroups(input)
	assert.NoError(t, err)
	assert.Len(t, result.CacheSubnetGroups, 1)

	return result.CacheSubnetGroups[0]
}

// Función para verificar los grupos de seguridad del clúster
func verifySecurityGroups(t *testing.T, svc *elasticache.ElastiCache, cluster *elasticache.CacheCluster, expectedSecurityGroups []string) []string {
	// Extrae los identificadores de los grupos de seguridad del clúster
	actualSecurityGroups := []string{}
	for _, sg := range cluster.SecurityGroups {
		actualSecurityGroups = append(actualSecurityGroups, *sg.SecurityGroupId)
	}
	return actualSecurityGroups
}
