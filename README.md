# Azure Storage Account and Log Analytics Integration

This project demonstrates deploying an Azure Storage Account with IP restrictions and associating it with a Log Analytics workspace using GitHub Actions and Bicep templates.

---

## Project Overview

This repository contains resources for deploying:
- A resource group.
- A storage account.
- A blob container with public access.
- IP restrictions to secure access.
- (Optional) Association with a Log Analytics workspace for monitoring.

---

## Folder Structure

```plaintext
.
├── .github
│   └── workflows
│       └── deploy-storage-account.yml  # GitHub Actions workflow file
├── bicep
│   └── storage-account.bicep           # Bicep template for storage account
├── README.md                           # Project documentation
