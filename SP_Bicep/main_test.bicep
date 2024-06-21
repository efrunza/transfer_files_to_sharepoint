@description('The abbreviated environment name where the resources will be deployed. It defaults to dev.')
@allowed([
  'dev'
  'prd'
])
param environment string = 'dev'

@description('The location the resources will be deployed to. It defaults to the Resource Group location.')
param location string = 'Canada East'

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

output deploymentName string = 'The deployment name is: ${deploymentName}'


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

var additionalSecrets = {
  MySecret: 'test'
  CertPassword: 'Athena123@'  
}

var certificateSecrets = {
  CertContent: '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'
}

//--------------------------------------------------------------------------------------
// Key Vault -- create new
//--------------------------------------------------------------------------------------
module keyVault 'modules/key-vault.bicep' = {
  name: 'kvef5'
  params: {
    location: location
    keyVaultName: resourceNames.outputs.keyVaultName
  }
}

output keyvaultid string = 'The keyvault id is: ${keyVault.outputs.keyVaultId}'

/*

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: 'kv-testbp-dev-002'
}

*/

//--------------------------------------------------------------------------------------
// Key Vault secrets -- create new
//--------------------------------------------------------------------------------------
module keyVaultSecrets 'modules/key-vault-secrets.bicep' = {
  name: '${deploymentName}-kv-secrets'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    otherSecrets: additionalSecrets
  }
  dependsOn: [
    keyVault
  ]
}

//--------------------------------------------------------------------------------------
// Key Vault certificate -- create new
//--------------------------------------------------------------------------------------
module keyVaultCertSecrets 'modules/key-vault-secrets_cert.bicep' = {
  name: '${deploymentName}-kv-cert-secrets'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    otherSecrets: certificateSecrets
  }
  dependsOn: [
    keyVault
  ]
}

/*

  // get an existing function app service principal
  resource function 'Microsoft.Web/sites@2023-01-01' existing = {
    name: 'TestSPNew'
  }

  output appId string = function.identity.principalId
*/


//--------------------------------------------------------------------------------------
// Function App -- create new
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
    appSettings: []
    corsDomains: []
  }
  dependsOn: [
    appServicePlan
  ]
}

output appId string = functionApp.outputs.principalId

//--------------------------------------------------------------------------------------
// Grant the Function App access to Key Vault -- create new
//--------------------------------------------------------------------------------------
module funcAppKeyVaultAccess 'modules/key-vault-access.bicep' = {
  name: '${deployment().name}-appreg-kv-access'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    principalId:  functionApp.outputs.principalId
  }
  dependsOn: [
    keyVault    
  ]
}

/*

module keyvaultcert 'modules/key-vault-certificate.bicep' = {
  name: 'certef4'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName   
     certificatePolicy: {
      issuerName: 'Self'
      subjectName: 'CN=${appName}-${instanceNumber}.azurewebsites.net'
      validityInMonths: 12
    }       
  }
}

*/

output storageAccountName string = 'The storage account name is: ${resourceNames.outputs.storageAccountName}'
output keyVaultName string = 'The key vault name is: ${resourceNames.outputs.keyVaultName}'
output appServicePlanId string = 'The app service plan id is: ${appServicePlan.outputs.appServicePlanId}'

