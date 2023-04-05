param name string
param location string = resourceGroup().location
param tags object = {}

//param apiBaseUrl string
param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
//param keyVaultName string
param serviceName string = 'web'

//param openAiName string = ''
param redisCacheServiceName string = ''
param redisCacheUseSslPort string = 'true'

var redisCachePort = redisCacheUseSslPort == 'false' ? redisCache.properties.port : redisCache.properties.sslPort

// @secure()
param openAiApiKey string = ''

// param redisCacheHost string
// param redisCachePort int = 6379
// @secure()
// param redisCachePrimaryKey string

module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    env: [
      {
        name: 'DATASTORE'
        value: 'redis'
      }
      {
        name: 'OPENAI_API_KEY'
        value: openAiApiKey
      }
      {
        name: 'BEARER_TOKEN'
        value: 'footoken'
      }
      {
        name: 'REDIS_HOST'
        value: redisCacheServiceName
      }
      {
        name: 'REDIS_PORT'
        value: string(6379)
      }
      {
        name: 'REDIS_PASSWORD'
        value: ''
      }
      {
        name: 'PORT'
        value: '80'
      }
      
      // {
      //   name: 'REACT_APP_APPLICATIONINSIGHTS_CONNECTION_STRING'
      //   value: applicationInsights.properties.ConnectionString
      // }
      // {
      //   name: 'REACT_APP_API_BASE_URL'
      //   value: apiBaseUrl
      // }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
    ]
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    //keyVaultName: keyVault.name
    targetPort: 80
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource redisCache 'Microsoft.Cache/redis@2022-06-01' existing = {
  name: redisCacheServiceName
}

// resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
//   name: keyVaultName
// }

output SERVICE_WEB_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output SERVICE_WEB_NAME string = app.outputs.name
output SERVICE_WEB_URI string = app.outputs.uri
output SERVICE_WEB_IMAGE_NAME string = app.outputs.imageName
