targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param apiContainerAppName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''
param cosmosAccountName string = ''
param cosmosDatabaseName string = ''
param keyVaultName string = ''
param logAnalyticsName string = ''
param resourceGroupName string = ''
param webContainerAppName string = ''
param apimServiceName string = ''
param redisContainerAppName string = ''
param redisImageName string = ''

@description('Flag to use Azure API Management to mediate the calls between the Web frontend and the backend API')
param useAPIM bool = false

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('The image name for the api service')
param apiImageName string = ''

@description('The image name for the web service')
param webImageName string = ''

@description('The base URL used by the web service for sending API requests')
param webApiBaseUrl string = ''

param redisCacheServiceName string = ''
param redisCacheUseSslPort string = 'true'

@secure()
param openAiApiKey string = ''


var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Container apps host (including container registry)
module containerApps './core/host/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    name: 'app'
    containerAppsEnvironmentName: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${abbrs.appManagedEnvironments}${resourceToken}'
    containerRegistryName: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
}

// Web frontend
module web './app/web.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: !empty(webContainerAppName) ? webContainerAppName : '${abbrs.appContainerApps}web-${resourceToken}'
    location: location
    imageName: webImageName
    //apiBaseUrl: !empty(webApiBaseUrl) ? webApiBaseUrl : api.outputs.SERVICE_API_URI
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
    openAiApiKey: openAiApiKey
    redisCacheName: !empty(redisCacheServiceName) ? redisCacheServiceName : redis.outputs.SERVICE_REDIS_NAME
    //keyVaultName: keyVault.outputs.name
  }
  dependsOn: [
    redis
  ]
}

module redis './app/redis.bicep' = {
  name: 'redis'
  scope: rg
  params: {
    name: !empty(redisCacheServiceName) ? redisCacheServiceName : '${abbrs.appContainerApps}redis-${resourceToken}'
    location: location
    imageName: redisImageName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
  }  
}

// module redis 'core/cache/redis.bicep' = {
//   name: 'redis'
//   scope: rg
//   params: {
//     name: !empty(redisCacheName) ? redisCacheName : '${abbrs.cacheRedis}${resourceToken}'
//     location: location
//     tags: tags
//     // redisCacheSKU: 'Enterprise'
//     // redisCacheFamily: 'E10'
//     // redisCacheCapacity: 2
//     enableNonSslPort: true
//   }
// }

// resource redisRef 'Microsoft.Cache/redis@2022-06-01' existing = {
//   name: redis.outputs.name
//   scope: rg
// }

// Api backend
// module api './app/api.bicep' = {
//   name: 'api'
//   scope: rg
//   params: {
//     name: !empty(apiContainerAppName) ? apiContainerAppName : '${abbrs.appContainerApps}api-${resourceToken}'
//     location: location
//     imageName: apiImageName
//     applicationInsightsName: monitoring.outputs.applicationInsightsName
//     containerAppsEnvironmentName: containerApps.outputs.environmentName
//     containerRegistryName: containerApps.outputs.registryName
//     keyVaultName: keyVault.outputs.name
//   }
// }

// Give the API access to KeyVault
// module apiKeyVaultAccess './core/security/keyvault-access.bicep' = {
//   name: 'api-keyvault-access'
//   scope: rg
//   params: {
//     keyVaultName: keyVault.outputs.name
//     principalId: api.outputs.SERVICE_API_IDENTITY_PRINCIPAL_ID
//   }
// }

// The application database
// module cosmos './app/db.bicep' = {
//   name: 'cosmos'
//   scope: rg
//   params: {
//     accountName: !empty(cosmosAccountName) ? cosmosAccountName : '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
//     databaseName: cosmosDatabaseName
//     location: location
//     tags: tags
//     keyVaultName: keyVault.outputs.name
//   }
// }

// Store secrets in a keyvault
// module keyVault './core/security/keyvault.bicep' = {
//   name: 'keyvault'
//   scope: rg
//   params: {
//     name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
//     location: location
//     tags: tags
//     principalId: principalId
//   }
// }

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

// Creates Azure API Management (APIM) service to mediate the requests between the frontend and the backend API
// module apim './core/gateway/apim.bicep' = if (useAPIM) {
//   name: 'apim-deployment'
//   scope: rg
//   params: {
//     name: !empty(apimServiceName) ? apimServiceName : '${abbrs.apiManagementService}${resourceToken}'
//     location: location
//     tags: tags
//     applicationInsightsName: monitoring.outputs.applicationInsightsName
//   }
// }

// Configures the API in the Azure API Management (APIM) service
// module apimApi './app/apim-api.bicep' = if (useAPIM) {
//   name: 'apim-api-deployment'
//   scope: rg
//   params: {
//     name: useAPIM ? apim.outputs.apimServiceName : ''
//     apiName: 'todo-api'
//     apiDisplayName: 'Simple Todo API'
//     apiDescription: 'This is a simple Todo API'
//     apiPath: 'todo'
//     webFrontendUrl: web.outputs.SERVICE_WEB_URI
//     //apiBackendUrl: api.outputs.SERVICE_API_URI
//   }
// }

// Data outputs
// output AZURE_COSMOS_CONNECTION_STRING_KEY string = cosmos.outputs.connectionStringKey
// output AZURE_COSMOS_DATABASE_NAME string = cosmos.outputs.databaseName

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output APPLICATIONINSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output AZURE_CONTAINER_ENVIRONMENT_NAME string = containerApps.outputs.environmentName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerApps.outputs.registryName
//output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
//output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
//output REACT_APP_API_BASE_URL string = useAPIM ? apimApi.outputs.SERVICE_API_URI : api.outputs.SERVICE_API_URI
output REACT_APP_APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI
//output SERVICE_API_NAME string = api.outputs.SERVICE_API_NAME
output SERVICE_WEB_NAME string = web.outputs.SERVICE_WEB_NAME
output USE_APIM bool = useAPIM
//output SERVICE_API_ENDPOINTS array = useAPIM ? [ apimApi.outputs.SERVICE_API_URI, api.outputs.SERVICE_API_URI ]: []

output SERVICE_REDIS_NAME string = redis.outputs.SERVICE_REDIS_NAME
output REDIS_CACHE_USE_SSL_PORT string = redisCacheUseSslPort
