param location string = 'UK West'
param resourceGroupName string
param storageAccountName string
param containerName string
param allowedIP string
param logAnalyticsWorkspaceName string

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
            defaultAction: 'Deny'
            ipRules: [
                {
                    action: 'Allow'
                    value: allowedIP
                }
            ]
        }
        accessTier: 'Hot'
    }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
    name: '${storageAccount.name}/default/${containerName}'
    properties: {
        publicAccess: 'None'
    }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
    name: logAnalyticsWorkspaceName
    location: location
    properties: {
        sku: {
            name: 'PerGB2018'
        }
    }
}
