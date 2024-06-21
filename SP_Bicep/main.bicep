/*

  # Deploying a Bicep File 
  # Azure CLI
  az login --only-show-errors -o table --query Dummy
  az account set -s $Subscription

  # Variables
. '.\00 Variables.ps1'

  # Need the RG first!
  az group create --name $RG --location $location

  # Deploy RG
  az deployment sub create --location $Location --template-file .\subscription-scope.bicep --parameters RG_Name=$RG location=$Location 

  // 4.- Deployment template to Azure
  // az deployment group create --template-file main.bicep --parameters ./devdeploy.parameters.json

  # Show result
  az resource list --resource-group $RG -o table

  # Delete RG
  az group delete -g $RG --yes

*/

@description('The abbreviated environment name where the resources will be deployed. It defaults to dev.')
@allowed([
  'dev'
  'prd'
])
param environment string = 'dev'

@description('The location the resources will be deployed to. It defaults to the Resource Group location.')
param location string = resourceGroup().location

@maxLength(15)
@description('The name of the app.')
param appName string = 'testbp' // resource name

@maxLength(3)
@description('The instance number for this resource. It defaults to 001.')
param instanceNumber string = '001'

@description('The Azure Function API version')
param apiVersion string = 'v1'

@description('The storage account type (sku). It defaults to Standard_LRS.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountSku string = 'Standard_LRS'

@description('The App Service Plan name for hosting the function app.')
param appServicePlanName string

@description('The App Service Plan resource group name.')
param appServicePlanGroup string

var deploymentName = deployment().name

//--------------------------------------------------------------------------------------
// Build resource names
//--------------------------------------------------------------------------------------
module resourceNames './modules/build-resource-names.bicep' = {
  name: '${deploymentName}-res-names'
  params: {
    environment: environment
    appName: appName
    instanceNumber: instanceNumber
  }
}

//--------------------------------------------------------------------------------------
// App Service Plan -- existing
//--------------------------------------------------------------------------------------
module appServicePlan './modules/app-service-plan.bicep' = {
  name: '${deploymentName}-asp'
  params: {
    appServicePlanGroup: appServicePlanGroup
    appServicePlanName: appServicePlanName
  }
}


/*

//--------------------------------------------------------------------------------------
// Key Vault
//--------------------------------------------------------------------------------------
module keyVault 'modules/key-vault.bicep' = {
  name: '${deploymentName}-kv'
  params: {
    location: location
    keyVaultName: resourceNames.outputs.keyVaultName
  }
}
*/

@secure()
param certificatePassword string

/*
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'testeffunc-asp'
  location: location
  sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  properties: {
    reserved: true    
  }
}
*/

//--------------------------------------------------------------------------------------
// Function App
//--------------------------------------------------------------------------------------
module functionApp 'modules/function-app.bicep' = {
  name: '${deploymentName}-func'
  params: {
    location: location
    functionAppName: resourceNames.outputs.functionAppName
    apiVersion: apiVersion
    storageAccountName: resourceNames.outputs.storageAccountName
    storageAccountSku: storageAccountSku
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    keyVaultName: resourceNames.outputs.keyVaultName
    appSettings: [       
        {
          name: 'KeyVaultName'
          value: '${deploymentName}-kv'
        }
        {
          name: 'CertificateName'
          value: '${deploymentName}-cert'
        }
      ]
    corsDomains: null
  }
  dependsOn: [
    appServicePlan    
  ]
}

output principalId string = 'The function principalId is: ${functionApp.outputs.principalId}'
output functionAppName string = 'The function name is: ${resourceNames.outputs.functionAppName}'

/*

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'testeffunc'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=myStorageAccount;AccountKey=myStorageAccountKey;EndpointSuffix=core.windows.net'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'KeyVaultName'
          value: '${deploymentName}-kv'
        }
        {
          name: 'CertificateName'
          value: '${deploymentName}-cert'
        }
      ]
    }
  }    
}
*/

/*
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${deploymentName}-kvef3'
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: functionApp.outputs.principalId
        permissions: {
          keys: ['get', 'create', 'delete', 'list', 'update', 'import', 'backup', 'restore', 'recover', 'purge']
          secrets: ['get', 'list', 'set', 'delete', 'backup', 'restore', 'recover', 'purge']
          certificates: ['get', 'list', 'delete', 'create', 'import', 'update', 'managecontacts', 'getissuers', 'listissuers', 'setissuers', 'deleteissuers', 'manageissuers', 'recover', 'purge']
        }      
      }
    ]
    enabledForDeployment: true
    enableSoftDelete: 
    enablePurgeProtection: true
    enableRbacAuthorization: true
  }
}
*/

//--------------------------------------------------------------------------------------
// Key Vault
//--------------------------------------------------------------------------------------
module keyVault 'modules/key-vault.bicep' = {
  name: '${deploymentName}-kv'
  params: {
    location: location
    keyVaultName: resourceNames.outputs.keyVaultName
  }
}

output keyvaultid string = 'The keyvault id is: ${keyVault.outputs.keyVaultId}'

/*

module keyvaultcert 'modules/key-vault-certificate.bicep' = {
  name: '${deploymentName}-cert'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    certificatePassword: certificatePassword
  }
  dependsOn: [
    keyVault
  ]
}

output certname string = 'The certificate name is: ${keyvaultcert.name}'

*/


/*

//--------------------------------------------------------------------------------------
// Key Vault
//--------------------------------------------------------------------------------------
module keyVault 'modules/key-vault.bicep' = {
  name: '${deploymentName}-kv'
  params: {
    location: location
    keyVaultName: resourceNames.outputs.keyVaultName
  }
}

//--------------------------------------------------------------------------------------
// Key Vault secrets
//--------------------------------------------------------------------------------------
module keyVaultSecrets 'modules/key-vault-secrets.bicep' = {
  name: '${deploymentName}-kv-secrets'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    otherSecrets: {}
  }
  dependsOn: [
    keyVault    
  ]
}

//--------------------------------------------------------------------------------------
// Function App
//--------------------------------------------------------------------------------------
module functionApp 'modules/function-app.bicep' = {
  name: '${deploymentName}-func'
  params: {
    location: location
    functionAppName: resourceNames.outputs.functionAppName
    apiVersion: apiVersion
    storageAccountName: resourceNames.outputs.storageAccountName
    storageAccountSku: storageAccountSku
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    keyVaultName: resourceNames.outputs.keyVaultName
    vnetSubnetId: ''
    appSettings: null
    corsDomains: null
  }
  dependsOn: [
    appServicePlan    
  ]
}

//--------------------------------------------------------------------------------------
// Grant the Function App access to Key Vault
//--------------------------------------------------------------------------------------
module funcAppKeyVaultAccess 'modules/key-vault-access.bicep' = {
  name: '${deployment().name}-func-kv-access'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    principalId: functionApp.outputs.principalId
  }
  dependsOn: [
    keyVault
    functionApp
  ]
}

//--------------------------------------------------------------------------------------
// Create API Management
//--------------------------------------------------------------------------------------

*/
