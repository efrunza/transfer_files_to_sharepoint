@description('Specifies the location for resources.')
param location string = 'canadaeast'

param vaults_EFSPKV2_name string = 'EFSPKV2'

resource vaults_EFSPKV2_name_resource 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaults_EFSPKV2_name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '70500bd2-4745-4d68-82bb-38476fa452bf'
    accessPolicies: [
      {
        tenantId: '70500bd2-4745-4d68-82bb-38476fa452bf'
        objectId: '41d96a63-0eec-44c9-a1f8-1eb562a4f981'
        permissions: {
          keys: [
            'Get'
            'List'
          ]
          secrets: [
            'Get'
            'List'
          ]
          certificates: [
            'Get'
            'List'
          ]
        }
      }
      {
        tenantId: '70500bd2-4745-4d68-82bb-38476fa452bf'
        objectId: '2b379d14-0d41-47bf-a1c6-230ddcc521c2'
        permissions: {
          keys: [
            'Get'
            'List'
          ]
          secrets: [
            'Get'
            'List'
          ]
          certificates: [
            'Get'
            'List'
          ]
        }
      }
      {
        tenantId: '70500bd2-4745-4d68-82bb-38476fa452bf'
        objectId: '3f74c614-258f-44f1-9c64-4076c7d83305'
        permissions: {
          keys: [
            'get'
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
            'import'
            'delete'
            'create'
            'update'
          ]
        }
      }
      {
        tenantId: '70500bd2-4745-4d68-82bb-38476fa452bf'
        objectId: '21b75634-bd3b-44d9-a53f-319a764c8290'
        permissions: {
          keys: [
            'get'
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: '70500bd2-4745-4d68-82bb-38476fa452bf'
        objectId: '01a8ca95-2014-482f-8104-87059148de56'
        permissions: {
          certificates: [
            'get'
            'list'
          ]
          keys: [
            'get'
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    vaultUri: 'https://efspkv2.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource vaults_EFSPKV2_name_SPOnline2 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  parent: vaults_EFSPKV2_name_resource
  name: 'SPOnline2'
  properties: {
    attributes: {
      enabled: true
      nbf: 1710181901
      exp: 1741719101
    }
  }
}

resource Microsoft_KeyVault_vaults_secrets_vaults_EFSPKV2_name_SPOnline2 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vaults_EFSPKV2_name_resource
  name: 'SPOnline2'
  properties: {
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1710181901
      exp: 1741719101
    }
  }
}
