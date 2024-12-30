name: Deploy Azure Storage Account

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
        az group create --name rrblobtest --location "UK West"

    - name: Deploy Storage Account
      run: |
        az deployment group create \
          --resource-group rrblobtest \
          --template-file bicep/storage-account.bicep \
          --parameters location="UK West" \
                      storageAccountName="test123434" \
                      containerName="images" \
                      allowedIP="92.16.42.251" \
                      logAnalyticsWorkspaceName="rrlogtest"
