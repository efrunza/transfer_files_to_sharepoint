@description('The abbreviated environment name where the resources will be deployed. It defaults to dev.')
@allowed([
  'dev'
  'prd'
])
param environment string = 'dev'

@maxLength(15)
@description('The name of the app.')
param appName string = 'testbp'

@maxLength(3)
@description('The instance number for this resource. It defaults to 001.')
param instanceNumber string = '001'

// set resource name based on resource name rules
var targetResourceName = '${appName}-${environment}-${instanceNumber}'

// key vault names must be globally unique, 3-24 characters in length, alphanumerics and hyphens, start with a letter and end with a letter or number
var keyVaultName = 'kv-${take(targetResourceName, 21)}'

// storage account names must be globally unique, 3 - 24 characters in length and use lowercase letters and numbers only
var storageAccountName = 'st${take(replace(targetResourceName, '-', ''), 22)}'

// function app names must be globally unique, 2-60 characters in length, alphanumeric, hyphens and Unicode characters and can't start or end with a hyphen
var functionAppName = 'func-${take(targetResourceName, 55)}'

output keyVaultName string = keyVaultName  
output storageAccountName string = storageAccountName
output functionAppName string = functionAppName
