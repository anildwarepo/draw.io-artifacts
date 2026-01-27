# Implementation Summary

## Requirements Met

✅ **Deployment Type Options**: Added support for two deployment types:
   - `GlobalStandard` (Standard pay-as-you-go)
   - `Provisioned` (PTU-based with reserved capacity)

✅ **Default Deployment Type**: Set `GlobalStandard` as the default value
   - Defined in `main.bicep` line 23: `param deploymentType string = 'GlobalStandard'`
   - Also set as default in `modules/cognitiveServices.bicep` line 24

✅ **Model Name as Parameter**: Model name is fully parameterized
   - Defined in `main.bicep` line 13: `param modelName string`
   - Can be set to any supported Azure OpenAI model (e.g., gpt-4, gpt-35-turbo, text-embedding-ada-002)
   - Used dynamically in deployment creation

## Implementation Details

### Files Created

1. **infra/main.bicep**
   - Main Bicep template at subscription scope
   - Creates resource group and deploys Azure OpenAI module
   - Contains all key parameters including deploymentType (with GlobalStandard default) and modelName

2. **infra/modules/cognitiveServices.bicep**
   - Module for creating Azure OpenAI Cognitive Services account
   - Creates deployment with conditional SKU based on deployment type:
     - GlobalStandard → SKU name: "Standard"
     - Provisioned → SKU name: "ProvisionedManaged" with capacity
   - Supports parameterized model name and version

3. **infra/parameters.globalstandard.json**
   - Example parameters file for GlobalStandard deployment
   - Shows how to configure with GlobalStandard deployment type

4. **infra/parameters.provisioned.json**
   - Example parameters file for Provisioned deployment
   - Shows how to configure with Provisioned deployment type and capacity

5. **infra/deploy.sh**
   - Bash script to simplify deployment process
   - Supports --type flag for choosing deployment type
   - Includes validation and what-if options

6. **infra/README.md**
   - Comprehensive documentation
   - Usage examples for both deployment types
   - Parameter descriptions
   - Deployment instructions

## Key Features

### Deployment Type Handling
The template uses a conditional expression to set the appropriate SKU:

```bicep
sku: deploymentType == 'Provisioned' ? {
  name: 'ProvisionedManaged'
  capacity: capacity
} : {
  name: 'Standard'
  capacity: null
}
```

### Parameters
- `deploymentType`: @allowed(['GlobalStandard', 'Provisioned']), default = 'GlobalStandard'
- `modelName`: string (required) - can be any Azure OpenAI model
- `modelVersion`: string, default = '0613'
- `capacity`: int, default = 100 (used only for Provisioned deployments)

### Example Usage

**GlobalStandard (Default):**
```bash
./deploy.sh --resource-group rg-openai --name openai-demo --model gpt-4
```

**Provisioned:**
```bash
./deploy.sh --type provisioned --resource-group rg-openai --name openai-prod --model gpt-4
```

## Validation

The implementation meets all requirements:
1. ✅ Deployment to AOAI with GlobalStandard option
2. ✅ Deployment to AOAI with Provisioned option
3. ✅ GlobalStandard is the default option
4. ✅ Model name is parameterized

All files follow Azure Bicep best practices and include proper documentation.
