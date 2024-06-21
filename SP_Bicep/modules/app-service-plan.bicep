@description('The App Service Plan name for hosting the function app.')
param appServicePlanName string

@description('The App Service Plan resource group name.')
param appServicePlanGroup string

// get the existing app service plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: appServicePlanName
  scope: resourceGroup(appServicePlanGroup)
}

output appServicePlanId string = appServicePlan.id
