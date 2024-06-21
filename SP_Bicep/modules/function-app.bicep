@description('The location the resources will be deployed to. It defaults to the Resource Group location.')
param location string

@minLength(3)
@maxLength(63)
@description('The Function App name.')
param functionAppName string

param apiVersion string

@minLength(3)
@maxLength(24)
@description('The Storage Account name.')
param storageAccountName string

@description('The storage account type (sku). It defaults to Standard_LRS.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountSku string = 'Standard_LRS'

@description('The App Service Plan id.')
param appServicePlanId string

@description('The Key Vault name.')
param keyVaultName string

@description('The comma separated list of allowed CORS domains')
param corsDomains array = []

@description('Additional application settings')
param appSettings array = []

var defaultCorsDomains = [
  'portal.azure.com'
  'functions.azure.com'
  'functions-staging.azure.com'
  'functions-next.azure.com'
]
var appCorsDomains = union(defaultCorsDomains, corsDomains)

// storage account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
}

// function app resource
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlanId
    clientAffinityEnabled: false
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      windowsFxVersion: 'DOTNET|6.0'
      ftpsState: 'Disabled'
      healthCheckPath: '/api/${apiVersion}/health'
      cors: {
        allowedOrigins: [for domain in appCorsDomains: 'https://${domain}']
        supportCredentials: true
      }
      minTlsVersion: '1.2'
      vnetRouteAllEnabled: true
      connectionStrings: []
      appSettings: concat([       
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }       
        {
          name: 'BlobContainerName'
          value: 'sharepointcontainer'
        }     
        {
          name: 'BlobStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=cs2100320034f236651;AccountKey===;EndpointSuffix=core.windows.net'
        }    
        {
          name: 'CertificateFromKV'
          value: ''
        }     
        {
          name: 'CertificateThumbPrint'
          value: '4b3a6c18400ba1b815cdae1a454bdf94c91d8335'
        }  
        {
          name: 'ClientId'
          value: '6732d354-3aed-4d24-ac70-edcd0493da2e'
        }     
        {
          name: 'DownloadScope'
          value: '@microsoft.graph.downloadUrl'
        }       
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'GraphScopes'
          value: 'https://graph.microsoft.com/.default'
        }  
        {
          name: 'GraphSiteUrl'
          value: 'planetitsp.sharepoint.com,7f079a8d-b250-4633-9362-9f2646a49175,f4779971-f888-4bc3-8b18-65f83b1f7aa7'
        }              
        {
          name: 'Secret1FromKV'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/CertContent/)'
        }    
        {
          name: 'Secret2FromKV'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/CertPassword/)'
        }    
        {
          name: 'SiteName'
          value: 'SiteToWorkWith'
        }       
        {
          name: 'SiteUrl'
          value: 'https://planetitsp.sharepoint.com/sites/PlanetITSP'
        }  
        {
          name: 'TenantId'
          value: '70500bd2-4745-4d68-82bb-38476fa452bf'
        }    
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }    
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'testspnew'
        }       
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }                            
      ], appSettings)
    }
  }
}

output hostName string = functionApp.properties.defaultHostName
output principalId string = functionApp.identity.principalId
