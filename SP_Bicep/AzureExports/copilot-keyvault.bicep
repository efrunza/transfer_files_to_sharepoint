@description('Specifies the location for resources.')
param location string 

@description('Specifies the tenant id.')
param tenantID string = '70500bd2-4745-4d68-82bb-38476fa452bf'


resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: 'SPEFKV'
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenantID
    accessPolicies: []
    enabledForDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

