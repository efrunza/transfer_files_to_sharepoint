@minLength(3)
@maxLength(24)
@description('The Key Vault name.')
param keyVaultName string
//param certificatePolicy object

// Get references to existing resources
//--------------------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: 'SPEFKV'
}

resource certificate 'Microsoft.KeyVault/vaults/certificates@2021-06-01-preview' = {
  parent: keyVault
  name: 'certef'
  /*
    properties: {
    certificatePolicy: certificatePolicy
  }
  */

}

output name string = certificate.name
