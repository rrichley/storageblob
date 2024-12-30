# Deploy Azure Resources

This repository demonstrates how to automate the deployment of Azure resources using GitHub Actions and Bicep templates. The workflow provisions a resource group, a storage account, and a blob container with restricted IP access, and associates a Log Analytics workspace for monitoring.

## Workflow Overview
The GitHub Actions workflow is triggered on a `push` to the `main` branch and performs the following steps:

1. Checks out the repository.
2. Logs in to Azure using a service principal.
3. Creates a resource group.
4. Deploys a storage account and blob container.
5. Configures diagnostic settings to send logs to a Log Analytics workspace.

### GitHub Actions Workflow File
```yaml
name: Deploy Azure Resources

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Create Resource Group
      run: |
        az group create --name rrblobtest --location "UK South"

    - name: Deploy Storage Account
      run: |
        az deployment group create \
          --resource-group rrblobtest \
          --template-file bicep/storage-account.bicep \
          --parameters location="UK South" \
                      storageAccountName="teststorage20241229" \
                      containerName="images" \
                      allowedIP="92.16.42.251"

    - name: Associate Log Analytics Workspace
      run: |
        az monitor diagnostic-settings create \
          --name "storageAccountDiagnostics" \
          --resource /subscriptions/929d7635-207a-4b22-8d24-34e2ae29092b/resourceGroups/rrblobtest/providers/Microsoft.Storage/storageAccounts/teststorage20241229 \
          --metrics '[{"category": "Transaction", "enabled": true}, {"category": "Capacity", "enabled": true}]' \
          --workspace /subscriptions/929d7635-207a-4b22-8d24-34e2ae29092b/resourceGroups/rrblobtest/providers/Microsoft.OperationalInsights/workspaces/rrlogtest
```

## Bicep Templates
The following Bicep templates are used for deploying the Log Analytics workspace and the storage account with the blob container.

### Log Analytics Workspace
```bicep
@description('The location for the Log Analytics workspace.')
param location string

@description('The name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
```

### Storage Account and Blob Container
```bicep
@description('The location for all resources.')
param location string

@description('The name of the storage account.')
param storageAccountName string

@description('The name of the container to create.')
param containerName string

@description('The IP address allowed to access the storage account.')
param allowedIP string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: allowedIP
          action: 'Allow'
        }
      ]
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'Blob'
  }
}
```

## How to Use
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-repo.git
   ```
2. **Set Up Azure Credentials:**
   Add the `AZURE_CREDENTIALS` secret to your GitHub repository. This should contain the JSON output from creating a service principal.

3. **Modify Parameters:**
   Update the Bicep template parameters as needed (e.g., `storageAccountName`, `allowedIP`).

4. **Push Changes:**
   Commit and push your changes to the `main` branch to trigger the workflow.

5. **Monitor Deployment:**
   Check the Actions tab in your GitHub repository for deployment logs.

## Resources
- [GitHub Actions for Azure](https://learn.microsoft.com/en-us/azure/developer/github/)  
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
