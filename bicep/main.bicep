resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rrblobtest'
  location: 'UK South'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'test123434'
  location: rg.location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '92.16.42.251'
        }
      ]
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccount.name}/default/images'
  properties: {
    publicAccess: 'None'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01' = {
  name: 'rrlogtest'
  location: rg.location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}
