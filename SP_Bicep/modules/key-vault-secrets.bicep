@minLength(3)
@maxLength(24)
@description('The Key Vault name.')
param keyVaultName string

@secure()
param otherSecrets object

//--------------------------------------------------------------------------------------
// Get references to existing resources
//--------------------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

//--------------------------------------------------------------------------------------
// Create secrets
//--------------------------------------------------------------------------------------
resource otherSecretResources 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for secret in items(otherSecrets): {
  name: '${keyVault.name}/${secret.key}'
  properties: {
    value: secret.value
  }
}]
