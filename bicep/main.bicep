param location string
param storageAccountName string
param containerName string
param allowedIP string
param logAnalyticsWorkspaceName string
param resourceGroupName string

// Create the Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Create Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
  scope: resourceGroup
}

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: [
        {
          value: allowedIP
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
  scope: resourceGroup
}

// Create Blob Service and Container
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: storageAccount
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}

// Associate Storage Account with Log Analytics Workspace
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'EnableDiagnostics'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
