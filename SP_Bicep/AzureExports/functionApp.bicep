@description('Specifies the location for resources.')
param location string = 'Canada East'

param sites_TestSPFiles_name string = 'TestSPFiles'
param serverfarms_ASP_EFLogicAppgroup_8ef4_externalid string = '/subscriptions/291398cd-87f4-4258-a8e3-9bd7ceaad64b/resourceGroups/EFLogicApp_group/providers/Microsoft.Web/serverfarms/ASP-EFLogicAppgroup-8ef4'

resource sites_TestSPFiles_name_resource 'Microsoft.Web/sites@2023-01-01' = {
  name: sites_TestSPFiles_name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: 'testspfiles.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: 'testspfiles.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_EFLogicAppgroup_8ef4_externalid
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '1D46FC7D6BF6ABD5680A5527ADE69D5D0E3F9DA4744688BDFEA2DAC8E06B6D33'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_TestSPFiles_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'ftp'
  properties: {
    allow: false
  }
}

resource sites_TestSPFiles_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'scm'
  properties: {
    allow: true
  }
}

resource sites_TestSPFiles_name_web 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$TestSPFiles'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 11091
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource sites_TestSPFiles_name_DownloadFileFromBlob 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'DownloadFileFromBlob'
  properties: {
    script_root_path_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/DownloadFileFromBlob/'
    script_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/bin/Demo.AzureFunction.dll'
    config_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/DownloadFileFromBlob/function.json'
    test_data_href: 'https://testspfiles.azurewebsites.net/admin/vfs/data/Functions/sampledata/DownloadFileFromBlob.dat'
    href: 'https://testspfiles.azurewebsites.net/admin/functions/DownloadFileFromBlob'
    config: {}
    invoke_url_template: 'https://testspfiles.azurewebsites.net/api/downloadfilefromblob'
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_TestSPFiles_name_DownloadFileFromSharePoint 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'DownloadFileFromSharePoint'
  properties: {
    script_root_path_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/DownloadFileFromSharePoint/'
    script_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/bin/Demo.AzureFunction.dll'
    config_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/DownloadFileFromSharePoint/function.json'
    test_data_href: 'https://testspfiles.azurewebsites.net/admin/vfs/data/Functions/sampledata/DownloadFileFromSharePoint.dat'
    href: 'https://testspfiles.azurewebsites.net/admin/functions/DownloadFileFromSharePoint'
    config: {}
    invoke_url_template: 'https://testspfiles.azurewebsites.net/api/downloadfilefromsharepoint'
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_TestSPFiles_name_ReadFileFromBlobUploadToSharePoint 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'ReadFileFromBlobUploadToSharePoint'
  properties: {
    script_root_path_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/ReadFileFromBlobUploadToSharePoint/'
    script_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/bin/Demo.AzureFunction.dll'
    config_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/ReadFileFromBlobUploadToSharePoint/function.json'
    test_data_href: 'https://testspfiles.azurewebsites.net/admin/vfs/data/Functions/sampledata/ReadFileFromBlobUploadToSharePoint.dat'
    href: 'https://testspfiles.azurewebsites.net/admin/functions/ReadFileFromBlobUploadToSharePoint'
    config: {}
    invoke_url_template: 'https://testspfiles.azurewebsites.net/api/readfilefromblobuploadtosharepoint'
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_TestSPFiles_name_ReadFileFromSQLUploadToSharePoint 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'ReadFileFromSQLUploadToSharePoint'
  properties: {
    script_root_path_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/ReadFileFromSQLUploadToSharePoint/'
    script_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/bin/Demo.AzureFunction.dll'
    config_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/ReadFileFromSQLUploadToSharePoint/function.json'
    test_data_href: 'https://testspfiles.azurewebsites.net/admin/vfs/data/Functions/sampledata/ReadFileFromSQLUploadToSharePoint.dat'
    href: 'https://testspfiles.azurewebsites.net/admin/functions/ReadFileFromSQLUploadToSharePoint'
    config: {}
    invoke_url_template: 'https://testspfiles.azurewebsites.net/api/readfilefromsqluploadtosharepoint'
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_TestSPFiles_name_UploadFileToBlob 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'UploadFileToBlob'
  properties: {
    script_root_path_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/UploadFileToBlob/'
    script_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/bin/Demo.AzureFunction.dll'
    config_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/UploadFileToBlob/function.json'
    test_data_href: 'https://testspfiles.azurewebsites.net/admin/vfs/data/Functions/sampledata/UploadFileToBlob.dat'
    href: 'https://testspfiles.azurewebsites.net/admin/functions/UploadFileToBlob'
    config: {}
    invoke_url_template: 'https://testspfiles.azurewebsites.net/api/uploadfiletoblob'
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_TestSPFiles_name_UploadFileToSharePoint 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: 'UploadFileToSharePoint'
  
  properties: {
    script_root_path_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/UploadFileToSharePoint/'
    script_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/bin/Demo.AzureFunction.dll'
    config_href: 'https://testspfiles.azurewebsites.net/admin/vfs/site/wwwroot/UploadFileToSharePoint/function.json'
    test_data_href: 'https://testspfiles.azurewebsites.net/admin/vfs/data/Functions/sampledata/UploadFileToSharePoint.dat'
    href: 'https://testspfiles.azurewebsites.net/admin/functions/UploadFileToSharePoint'
    config: {}
    invoke_url_template: 'https://testspfiles.azurewebsites.net/api/uploadfiletosharepoint'
    language: 'DotNetAssembly'
    isDisabled: false
  }
}

resource sites_TestSPFiles_name_sites_TestSPFiles_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-01-01' = {
  parent: sites_TestSPFiles_name_resource
  name: '${sites_TestSPFiles_name}.azurewebsites.net'
  
  properties: {
    siteName: 'TestSPFiles'
    hostNameType: 'Verified'
  }
}
