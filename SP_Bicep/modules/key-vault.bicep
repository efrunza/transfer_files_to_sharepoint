@description('The location the resources will be deployed to. It defaults to the Resource Group location.')
param location string

@minLength(3)
@maxLength(24)
@description('The Key Vault name.')
param keyVaultName string

@description('The Key Vault SKU. It defaults to standard.')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: [      
    ]
  }
}

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
