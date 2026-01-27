# Azure OpenAI Infrastructure Deployment

This directory contains Bicep templates for deploying Azure OpenAI resources with different deployment types.

## Features

- **Deployment Types**: Supports both GlobalStandard (pay-as-you-go) and Provisioned (PTU-based) deployments
- **Default Configuration**: GlobalStandard is set as the default deployment type
- **Parameterized Model Name**: Model name is configurable as a parameter
- **Flexible Configuration**: Supports various Azure OpenAI models (GPT-4, GPT-3.5-Turbo, embeddings, etc.)

## Files

- `main.bicep`: Main template that orchestrates the deployment at subscription scope
- `modules/cognitiveServices.bicep`: Module for creating Azure OpenAI resource and deployment
- `parameters.globalstandard.json`: Example parameters for GlobalStandard deployment
- `parameters.provisioned.json`: Example parameters for Provisioned deployment
- `deploy.sh`: Bash script to simplify deployment process

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `resourceGroupName` | string | - | Name of the resource group |
| `location` | string | deployment().location | Azure region for resources |
| `openAIName` | string | - | Name of the Azure OpenAI resource |
| `modelName` | string | - | Model to deploy (e.g., gpt-4, gpt-35-turbo) |
| `modelVersion` | string | 0613 | Version of the model |
| `deploymentType` | string | GlobalStandard | Deployment type (GlobalStandard or Provisioned) |
| `deploymentName` | string | {modelName}-deployment | Name for the deployment |
| `capacity` | int | 100 | Capacity for Provisioned deployments (PTUs) |

## Deployment Types

### GlobalStandard (Default)
- Pay-as-you-go pricing model
- Standard deployment with automatic scaling
- Best for development and variable workloads
- No capacity reservations required

### Provisioned
- PTU (Provisioned Throughput Units) based pricing
- Reserved capacity for consistent performance
- Best for production workloads with predictable traffic
- Requires capacity parameter (PTUs)

## Usage

### Using the Deployment Script (Recommended)

The `deploy.sh` script provides a simplified way to deploy the Azure OpenAI resources:

```bash
# Deploy with GlobalStandard (default)
./deploy.sh --resource-group rg-openai --name openai-demo --model gpt-4

# Deploy with Provisioned
./deploy.sh --type provisioned --resource-group rg-openai --name openai-prod --model gpt-4

# Validate before deploying
./deploy.sh --validate --resource-group rg-openai --name openai-demo --model gpt-4

# Preview changes (what-if)
./deploy.sh --what-if --resource-group rg-openai --name openai-demo --model gpt-4
```

### Deploy with Azure CLI Directly

#### Deploy with GlobalStandard (Default)

```bash
az deployment sub create \
  --name openai-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters parameters.globalstandard.json
```

### Deploy with Provisioned

```bash
az deployment sub create \
  --name openai-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters parameters.provisioned.json
```

### Deploy with inline parameters

```bash
az deployment sub create \
  --name openai-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters \
    resourceGroupName=rg-openai \
    openAIName=openai-demo-001 \
    modelName=gpt-35-turbo \
    deploymentType=GlobalStandard
```

## Supported Models

Common model names you can use:
- `gpt-4` - GPT-4 model
- `gpt-4-32k` - GPT-4 with 32K context
- `gpt-35-turbo` - GPT-3.5 Turbo
- `gpt-35-turbo-16k` - GPT-3.5 Turbo with 16K context
- `text-embedding-ada-002` - Text embeddings model
- `text-davinci-003` - Davinci model

Check [Azure OpenAI Service models](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models) for the latest available models and versions.

## Validation

To validate the template before deployment:

```bash
az deployment sub validate \
  --location eastus \
  --template-file main.bicep \
  --parameters parameters.globalstandard.json
```

## What-If Analysis

To preview changes without deploying:

```bash
az deployment sub what-if \
  --location eastus \
  --template-file main.bicep \
  --parameters parameters.globalstandard.json
```

## Outputs

After deployment, the following outputs are available:
- `openAIId`: Resource ID of the Azure OpenAI account
- `openAIName`: Name of the Azure OpenAI account
- `openAIEndpoint`: Endpoint URL for the Azure OpenAI account
- `deploymentName`: Name of the model deployment
- `deploymentType`: The deployment type used (GlobalStandard or Provisioned)

## Notes

- The default deployment type is **GlobalStandard**
- For Provisioned deployments, ensure you have sufficient PTU quota in your subscription
- Model availability varies by region - check Azure OpenAI documentation for region-specific model availability
- The `versionUpgradeOption` is set to `OnceNewDefaultVersionAvailable` for automatic updates to new default versions

## Prerequisites

- Azure CLI installed and logged in
- Appropriate Azure permissions to create resources
- Azure OpenAI service access (request required if not already enabled)

## Clean Up

To delete the deployed resources:

```bash
az group delete --name <resourceGroupName> --yes --no-wait
```
