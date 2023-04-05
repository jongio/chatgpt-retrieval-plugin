param name string
param location string = resourceGroup().location
param tags object = {}

//param apiBaseUrl string
//param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
//param keyVaultName string
param serviceName string = 'redis'

module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    imageName: !empty(imageName) ? imageName : 'redis/redis-stack-server:latest'
    //keyVaultName: keyVault.name
    targetPort: 6379
    transport: 'tcp'
    external: false
  }
}


output SERVICE_REDIS_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output SERVICE_REDIS_NAME string = app.outputs.name
output SERVICE_REDIS_URI string = app.outputs.uri
output SERVICE_REDIS_IMAGE_NAME string = app.outputs.imageName
