param keyVaultName string
param certificateName string
param certificatePolicy object
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
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
        objectId: 'YOUR_OBJECT_ID'
        permissions: {
          keys: ['get', 'create', 'delete', 'list', 'update', 'import', 'backup', 'restore', 'recover', 'purge']
          secrets: ['get', 'list', 'set', 'delete', 'backup', 'restore', 'recover', 'purge']
          certificates: ['get', 'list', 'delete', 'create', 'import', 'update', 'managecontacts', 'getissuers', 'listissuers', 'setissuers', 'deleteissuers', 'manageissuers', 'recover', 'purge']
        }
      }
    ]
    enableSoftDelete: true
    enablePurgeProtection: true
  }
}

resource certificate 'Microsoft.KeyVault/vaults/certificates@2021-06-01-preview' = {
  parent: keyVault
  name: certificateName
  properties: {
    certificatePolicy: certificatePolicy
  }
}
