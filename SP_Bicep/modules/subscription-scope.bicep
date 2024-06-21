targetScope = 'subscription'

param RG_Name string
param location string

resource bicepRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG_Name
  location: location
}

output name string = bicepRG.name
